#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ID="${1:-$(date +%F-%H%M%S)}"
OUT="$ROOT/evidence/$RUN_ID"
mkdir -p "$OUT"
RESULTS="$OUT/security-test-results.md"
RAW="$OUT/security-test-raw.jsonl"
: > "$RAW"

NS="irestrict-apps"
SERVICE="http://sample-financial-api.irestrict-apps.svc.cluster.local"
RUNNER="validation-runner-$RUN_ID"

{
  echo "Run ID: $RUN_ID"
  echo "Collected: $(date -Is)"
  echo "Namespace: $NS"
  echo "Target service: $SERVICE"
  echo -n "Kubernetes context: "
  kubectl config current-context 2>/dev/null || true
} > "$OUT/validation-context.txt"

kubectl get nodes -o wide > "$OUT/pre-validation-nodes.txt" 2>&1 || true
kubectl get pods -A -o wide > "$OUT/pre-validation-pods.txt" 2>&1 || true

RUNNER="validation-runner-$RUN_ID"
RUNNER="${RUNNER//:/-}"
RUNNER="${RUNNER//_/-}"
RUNNER="$(printf '%s' "$RUNNER" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9.-]+/-/g; s/^[^a-z0-9]+//; s/[^a-z0-9]+$//' | cut -c1-63)"

kubectl delete pod "$RUNNER" -n "$NS" --ignore-not-found >/dev/null 2>&1 || true
kubectl run "$RUNNER" -n "$NS" --image=curlimages/curl:8.10.1 --restart=Never --command -- sleep 3600 >/dev/null
kubectl wait --for=condition=Ready pod/"$RUNNER" -n "$NS" --timeout=120s >/dev/null

cleanup() {
  kubectl delete pod "$RUNNER" -n "$NS" --ignore-not-found >/dev/null 2>&1 || true
}
trap cleanup EXIT

run_case() {
  local id="$1" scenario="$2" expected_code="$3" method="$4" path="$5" headers="$6"
  local url="$SERVICE$path"
  local start end elapsed output code body status
  start=$(date +%s%3N)
  set +e
  output=$(kubectl exec -n "$NS" "$RUNNER" -- sh -c "curl -sS -X '$method' -w '\nHTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}\n' $headers '$url'" 2>&1)
  status=$?
  set -e
  end=$(date +%s%3N)
  elapsed=$((end-start))
  code=$(printf '%s\n' "$output" | awk -F: '/^HTTP_CODE:/ {print $2}' | tail -1)
  body=$(printf '%s\n' "$output" | sed '/^HTTP_CODE:/,$d')
  [[ -z "$code" ]] && code="000"
  local actual result
  if [[ "$code" == "$expected_code" ]]; then
    actual="HTTP $code"
    result="Pass"
  else
    actual="HTTP $code"
    result="Fail"
  fi
  printf '{"id":"%s","scenario":"%s","expected":"HTTP %s","actual":"%s","result":"%s","elapsed_ms":%s,"body":%s}\n' \
    "$id" "$scenario" "$expected_code" "$actual" "$result" "$elapsed" "$(printf '%s' "$body" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" >> "$RAW"
}

run_case T00 "Health endpoint" 200 GET /healthz ""
run_case T01 "Valid OPA decision with scope, DPoP, mTLS, and SPIFFE-style workload identity" 200 GET /v1/accounts "-H 'x-demo-scope: accounts.read' -H 'x-demo-dpop: true' -H 'x-demo-mtls: true'"
run_case T02 "Stolen token simulation without DPoP proof" 403 GET /v1/accounts "-H 'x-demo-scope: accounts.read' -H 'x-demo-mtls: true'"
run_case T03 "Invalid mTLS context" 403 GET /v1/accounts "-H 'x-demo-scope: accounts.read' -H 'x-demo-dpop: true' -H 'x-demo-mtls: false'"
run_case T04 "Wrong workload identity" 403 GET /v1/accounts "-H 'x-demo-scope: accounts.read' -H 'x-demo-dpop: true' -H 'x-demo-mtls: true' -H 'x-demo-spiffe-id: spiffe://miva.local/ns/default/sa/unknown'"
run_case T05 "Unauthorized scope for account read" 403 GET /v1/accounts "-H 'x-demo-scope: payments.write' -H 'x-demo-dpop: true' -H 'x-demo-mtls: true'"
run_case T06 "High-risk payment context denied" 403 POST /v1/payments "-H 'x-demo-scope: payments.write' -H 'x-demo-dpop: true' -H 'x-demo-mtls: true' -H 'x-demo-risk: high'"
run_case T07 "Valid payment context allowed" 200 POST /v1/payments "-H 'x-demo-scope: payments.write' -H 'x-demo-dpop: true' -H 'x-demo-mtls: true' -H 'x-demo-risk: low'"

python3 - "$RAW" "$RESULTS" <<'PY'
import json, sys, statistics, datetime
raw, out = sys.argv[1:3]
rows = [json.loads(line) for line in open(raw) if line.strip()]
latencies = [r["elapsed_ms"] for r in rows if r["result"] == "Pass"]
with open(out, "w") as f:
    f.write("# iRestrict Security Validation Results\n\n")
    f.write(f"Collected: {datetime.datetime.now().astimezone().isoformat()}\n\n")
    f.write("| Test ID | Scenario | Expected Result | Actual Result | Status | Evidence |\n")
    f.write("|---|---|---:|---:|---|---|\n")
    for r in rows:
        body = r["body"].replace("\n", " ")[:180].replace("|", "/")
        f.write(f"| {r['id']} | {r['scenario']} | {r['expected']} | {r['actual']} | {r['result']} | {body} |\n")
    f.write("\n## Latency observation\n\n")
    if latencies:
        f.write(f"Mean observed command round-trip latency: {statistics.mean(latencies):.2f} ms. ")
        f.write(f"Minimum: {min(latencies)} ms. Maximum: {max(latencies)} ms.\n")
    else:
        f.write("No passing latency observations were available.\n")
    f.write("\n## Interpretation\n\n")
    f.write("The tests show policy-based allow and deny behavior for identity, DPoP-style proof, mTLS-style verification, SPIFFE-style workload identity, route authorization, and contextual risk. The proof signals are represented as controlled validation headers in the prototype API so the dissertation can demonstrate the authorization logic without relying on production certificates or live banking data.\n")
    f.write("\n## STRIDE interpretation\n\n")
    f.write("T01-T05 primarily exercise Spoofing and Elevation-of-Privilege controls; T06 exercises contextual authorization against Elevation of Privilege; T00 is an availability check relevant to Denial of Service. These tests do not, by themselves, fully validate Tampering, Repudiation, Information Disclosure, or load-based Denial of Service. See docs/stride-test-plan.md for the explicit coverage and evidence requirements.\n")
PY

kubectl get nodes -o wide > "$OUT/post-validation-nodes.txt" 2>&1 || true
kubectl get pods -A -o wide > "$OUT/post-validation-pods.txt" 2>&1 || true

cat "$RESULTS"
echo "Validation results written to $RESULTS"
