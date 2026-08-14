#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ID="${1:-$(date +%F-%H%M%S)}"
OUT="$ROOT/evidence/$RUN_ID"
mkdir -p "$OUT"
NS="irestrict-apps"
SERVICE="http://sample-financial-api.irestrict-apps.svc.cluster.local"
JOB="k6-benchmark-${RUN_ID//:/-}"
JOB="${JOB//_/-}"
CM="${JOB}-script"

cat > "$OUT/k6-script.js" <<'JS'
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Counter, Rate, Trend } from 'k6/metrics';

const baselineDuration = new Trend('baseline_duration', true);
const securedDuration = new Trend('secured_duration', true);
const baselineRequests = new Counter('baseline_requests');
const securedRequests = new Counter('secured_requests');
const baselineFailures = new Rate('baseline_failures');
const securedFailures = new Rate('secured_failures');

export const options = {
  scenarios: {
    baseline: {
      executor: 'constant-vus',
      vus: Number(__ENV.VUS || 50),
      duration: __ENV.DURATION || '45s',
      startTime: __ENV.BASELINE_START || '0s',
      exec: 'baseline',
    },
    secured: {
      executor: 'constant-vus',
      vus: Number(__ENV.VUS || 50),
      duration: __ENV.DURATION || '45s',
      startTime: __ENV.SECURED_START || '55s',
      exec: 'secured',
    },
  },
  thresholds: {
    'http_req_failed{path:baseline}': ['rate<0.05'],
    'http_req_failed{path:secured}': ['rate<0.05'],
    'http_req_duration{path:baseline}': ['max>=0'],
    'http_req_duration{path:secured}': ['max>=0'],
  },
};

const base = __ENV.SERVICE_URL;

export function baseline() {
  const r = http.get(`${base}/v1/accounts`, {
    headers: {
      'x-demo-scope': 'accounts.read',
      'x-demo-dpop': 'true',
      'x-demo-mtls': 'true',
      'x-benchmark-response': 'true',
      'x-benchmark-bypass': 'true',
    },
    tags: { path: 'baseline' },
  });
  baselineDuration.add(r.timings.duration);
  baselineRequests.add(1);
  baselineFailures.add(r.status !== 200);
  check(r, { 'baseline 200': (res) => res.status === 200 });
}

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
  securedDuration.add(r.timings.duration);
  securedRequests.add(1);
  securedFailures.add(r.status !== 200);
  check(r, { 'secured 200': (res) => res.status === 200 });
}
JS

kubectl delete job "$JOB" -n "$NS" --ignore-not-found >/dev/null 2>&1 || true
kubectl delete configmap "$CM" -n "$NS" --ignore-not-found >/dev/null 2>&1 || true
kubectl create configmap "$CM" -n "$NS" --from-file=k6-script.js="$OUT/k6-script.js" >/dev/null
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
        app: k6-benchmark
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
            - name: VUS
              value: "${K6_VUS:-50}"
            - name: DURATION
              value: "${K6_DURATION:-45s}"
            - name: SECURED_START
              value: "${K6_SECURED_START:-55s}"
            - name: BASELINE_START
              value: "${K6_BASELINE_START:-0s}"
          command: ["k6", "run", "--summary-trend-stats", "avg,min,med,p(90),p(95),p(99),max", "/scripts/k6-script.js"]
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
kubectl logs -n "$NS" job/"$JOB" > "$OUT/k6-benchmark.log" 2>&1 || true
kubectl get job "$JOB" -n "$NS" -o yaml > "$OUT/k6-job.yaml" 2>&1 || true

python3 - "$OUT/k6-benchmark.log" "$OUT/k6-benchmark-summary.md" <<'PY'
import re, sys
log=open(sys.argv[1], errors='ignore').read()
out=['# k6 Matched Baseline vs Secured Policy-Path Benchmark','', 'This benchmark ran inside the Kubernetes cluster using grafana/k6. Both paths call the same `/v1/accounts` endpoint with the same request context and response shape. The lab-only baseline bypasses the OPA call; the secured path performs the OPA decision. This isolates application-plus-policy-path overhead, not production DPoP, certificate-bound mTLS, SPIFFE federation, or internet latency.', '']
for line in log.splitlines():
    if 'http_req_duration' in line or 'http_req_failed' in line or 'checks' in line:
        out.append('```text')
        break
if out[-1]=='```text':
    for line in log.splitlines():
        if any(k in line for k in ['baseline_duration','secured_duration','baseline_requests','secured_requests','baseline_failures','secured_failures','http_req_duration','http_req_failed','checks','iterations','vus','data_received','data_sent']):
            out.append(line)
    out.append('```')
else:
    out.append('No k6 summary lines parsed; inspect k6-benchmark.log.')
open(sys.argv[2],'w').write('\n'.join(out)+'\n')
PY

if [[ "$WAIT_STATUS" -ne 0 ]]; then
  echo "k6 job did not complete successfully; see $OUT/k6-benchmark.log" >&2
  exit "$WAIT_STATUS"
fi

echo "$OUT"
