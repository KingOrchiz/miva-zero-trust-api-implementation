#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ID="${1:-standard-300rps-$(date -u +%Y%m%dT%H%M%SZ)}"
RATE="${K6_RATE:-300}"
DURATION="${K6_DURATION:-60s}"
PRE_VUS="${K6_PREALLOCATED_VUS:-150}"
MAX_VUS="${K6_MAX_VUS:-600}"
OUT="$ROOT/evidence/$RUN_ID"
NS="irestrict-apps"
SERVICE="http://sample-financial-api.irestrict-apps.svc.cluster.local"
JOB="k6-standard-${RUN_ID//_/-}"
JOB="${JOB//:/-}"
CM="${JOB}-script"
mkdir -p "$OUT"

kubectl -n "$NS" get pods -l app=sample-financial-api -o wide > "$OUT/pods-before.txt"
kubectl -n "$NS" get pods -l app=sample-financial-api \
  -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.containerStatuses[0].restartCount}{"\n"}{end}' \
  > "$OUT/restarts-before.txt"

cat > "$OUT/k6-standard.js" <<'JS'
import http from 'k6/http';
import { check } from 'k6';

export const options = {
  scenarios: {
    secured_standard: {
      executor: 'constant-arrival-rate',
      rate: Number(__ENV.RATE),
      timeUnit: '1s',
      duration: __ENV.DURATION,
      preAllocatedVUs: Number(__ENV.PRE_VUS),
      maxVUs: Number(__ENV.MAX_VUS),
      exec: 'secured',
      tags: { path: 'secured', standard_rate: String(__ENV.RATE) },
    },
  },
  thresholds: {
    'http_req_failed{path:secured}': ['rate<0.01'],
    'http_req_duration{path:secured}': ['max>=0'],
    dropped_iterations: ['count==0'],
  },
};

const base = __ENV.SERVICE_URL;
export function secured() {
  const r = http.get(`${base}/v1/accounts`, {
    headers: {
      'x-demo-scope': 'accounts.read',
      'x-demo-dpop': 'true',
      'x-demo-mtls': 'true',
      'x-benchmark-response': 'true',
    },
    tags: { path: 'secured' },
  });
  check(r, { 'secured 200': (res) => res.status === 200 });
}
JS

kubectl delete job "$JOB" -n "$NS" --ignore-not-found >/dev/null 2>&1 || true
kubectl delete configmap "$CM" -n "$NS" --ignore-not-found >/dev/null 2>&1 || true
kubectl create configmap "$CM" -n "$NS" --from-file=k6-standard.js="$OUT/k6-standard.js" >/dev/null
cat <<YAML | kubectl apply -f - >/dev/null
apiVersion: batch/v1
kind: Job
metadata:
  name: $JOB
  namespace: $NS
spec:
  backoffLimit: 0
  template:
    metadata:
      labels:
        app: k6-standard
    spec:
      restartPolicy: Never
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchLabels:
                  app: opa
              namespaces:
                - irestrict-security
              topologyKey: kubernetes.io/hostname
      containers:
        - name: k6
          image: grafana/k6:0.55.0
          resources:
            requests:
              cpu: 250m
              memory: 256Mi
            limits:
              cpu: "1"
              memory: 512Mi
          env:
            - name: SERVICE_URL
              value: "$SERVICE"
            - name: RATE
              value: "$RATE"
            - name: DURATION
              value: "$DURATION"
            - name: PRE_VUS
              value: "$PRE_VUS"
            - name: MAX_VUS
              value: "$MAX_VUS"
          command: ["k6", "run", "--summary-trend-stats", "avg,min,med,p(90),p(95),p(99),max", "/scripts/k6-standard.js"]
          volumeMounts:
            - name: script
              mountPath: /scripts
      volumes:
        - name: script
          configMap:
            name: $CM
YAML

set +e
kubectl wait --for=condition=complete job/"$JOB" -n "$NS" --timeout=180s > "$OUT/k6-wait.txt" 2>&1
WAIT_STATUS=$?
set -e
kubectl logs -n "$NS" job/"$JOB" > "$OUT/k6-standard.log" 2>&1 || true
kubectl get job "$JOB" -n "$NS" -o yaml > "$OUT/k6-job.yaml" 2>&1 || true
kubectl get pods -n "$NS" -l job-name="$JOB" -o wide > "$OUT/k6-placement.txt" 2>&1 || true

kubectl -n "$NS" get pods -l app=sample-financial-api -o wide > "$OUT/pods-after.txt"
kubectl -n "$NS" get pods -l app=sample-financial-api \
  -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.containerStatuses[0].restartCount}{"\n"}{end}' \
  > "$OUT/restarts-after.txt"
kubectl -n "$NS" run "health-${RUN_ID//_/-}" --rm -i --restart=Never --image=curlimages/curl:8.10.1 \
  --command -- curl -fsS "$SERVICE/healthz" > "$OUT/health-after.txt" 2>&1

python3 - "$OUT/k6-standard.log" "$OUT/k6-standard-summary.md" "$RATE" "$DURATION" <<'PY'
import sys
log, out, rate, duration = sys.argv[1:]
lines = open(log, errors='ignore').read().splitlines()
keys = ('checks', 'dropped_iterations', 'http_req_duration', 'http_req_failed', 'http_reqs', 'iterations', 'vus')
selected = [line for line in lines if any(key in line for key in keys)]
text = [
    '# k6 Fixed-Rate Secured-Path Standard', '',
    f'Offered rate: {rate} requests/second',
    f'Duration: {duration}', '', '```text', *selected, '```',
]
open(out, 'w').write('\n'.join(text) + '\n')
PY

if [[ "$WAIT_STATUS" -ne 0 ]]; then
  echo "Standard-rate job failed or missed a threshold; inspect $OUT/k6-standard.log" >&2
  exit "$WAIT_STATUS"
fi

if ! diff -u "$OUT/restarts-before.txt" "$OUT/restarts-after.txt" > "$OUT/restart-diff.txt"; then
  echo "Pod restart counts changed; inspect $OUT/restart-diff.txt" >&2
  exit 1
fi

echo "Standard test evidence: $OUT"
cat "$OUT/k6-standard-summary.md"
