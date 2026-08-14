#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ID="${1:-$(date +%F-%H%M%S)}"
OUT="$ROOT/evidence/$RUN_ID"
mkdir -p "$OUT"
NS="irestrict-apps"
SERVICE="http://sample-financial-api.irestrict-apps.svc.cluster.local"
JOB="k6-capacity-${RUN_ID//_/-}"
CM="${JOB}-script"

cat > "$OUT/k6-capacity.js" <<'JS'
import http from 'k6/http';
import { check } from 'k6';

const rates = [500, 1000, 2000, 5000, 10000];
const scenarios = {};
for (let i = 0; i < rates.length; i++) {
  const name = `rps_${rates[i]}`;
  scenarios[name] = {
    executor: 'constant-arrival-rate',
    rate: rates[i],
    timeUnit: '1s',
    duration: '10s',
    startTime: `${i * 15}s`,
    preAllocatedVUs: Math.min(1200, Math.max(100, Math.ceil(rates[i] * 0.12))),
    maxVUs: 1600,
    exec: 'secured',
    tags: { offered_rate: String(rates[i]) },
  };
}

const thresholds = {};
for (const rate of rates) {
  thresholds[`http_req_duration{offered_rate:${rate}}`] = ['max>=0'];
  thresholds[`http_req_failed{offered_rate:${rate}}`] = ['rate<1'];
}

export const options = { scenarios, thresholds };
const base = __ENV.SERVICE_URL;

export function secured() {
  const r = http.get(`${base}/v1/accounts`, {
    headers: {
      'x-demo-scope': 'accounts.read',
      'x-demo-dpop': 'true',
      'x-demo-mtls': 'true',
      'x-benchmark-response': 'true',
    },
  });
  check(r, { 'secured 200': (res) => res.status === 200 });
}
JS

kubectl delete job "$JOB" -n "$NS" --ignore-not-found >/dev/null 2>&1 || true
kubectl delete configmap "$CM" -n "$NS" --ignore-not-found >/dev/null 2>&1 || true
kubectl create configmap "$CM" -n "$NS" --from-file=k6-capacity.js="$OUT/k6-capacity.js" >/dev/null
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
        app: k6-capacity
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
              cpu: 500m
              memory: 256Mi
            limits:
              cpu: "1"
              memory: 512Mi
          env:
            - name: SERVICE_URL
              value: "$SERVICE"
          command: ["k6", "run", "--summary-trend-stats", "avg,min,med,p(90),p(95),p(99),max", "/scripts/k6-capacity.js"]
          volumeMounts:
            - name: script
              mountPath: /scripts
      volumes:
        - name: script
          configMap:
            name: $CM
YAML

set +e
kubectl wait --for=condition=complete job/"$JOB" -n "$NS" --timeout=240s > "$OUT/k6-capacity-wait.txt" 2>&1
status=$?
set -e
kubectl logs -n "$NS" job/"$JOB" > "$OUT/k6-capacity.log" 2>&1 || true
kubectl get job "$JOB" -n "$NS" -o yaml > "$OUT/k6-capacity-job.yaml" 2>&1 || true
if [[ "$status" -ne 0 ]]; then
  echo "Capacity job did not complete; inspect $OUT/k6-capacity.log" >&2
  exit "$status"
fi
echo "$OUT"
