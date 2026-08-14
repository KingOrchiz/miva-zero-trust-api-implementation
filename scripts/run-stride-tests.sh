#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ID="${1:-stride-$(date -u +%Y%m%dT%H%M%SZ)}"
OUT="$ROOT/evidence/$RUN_ID"
NS="irestrict-apps"
SERVICE="http://sample-financial-api.irestrict-apps.svc.cluster.local"
RUNNER="$(printf 'stride-runner-%s' "$RUN_ID" | tr '[:upper:]_' '[:lower:]-' | sed -E 's/[^a-z0-9.-]+/-/g; s/^[^a-z0-9]+//; s/[^a-z0-9]+$//' | cut -c1-63)"
RAW="$OUT/stride-results.jsonl"
REPORT="$OUT/stride-results.md"

[[ -n "${KUBECONFIG:-}" ]] || { echo "Set KUBECONFIG explicitly." >&2; exit 2; }
[[ "${STRIDE_MIVA_CONFIRMED:-}" == "true" ]] || { echo "Set STRIDE_MIVA_CONFIRMED=true after verifying the lab target." >&2; exit 2; }
mkdir -p "$OUT"
: > "$RAW"

kubectl delete pod "$RUNNER" -n "$NS" --ignore-not-found >/dev/null 2>&1 || true
kubectl run "$RUNNER" -n "$NS" --image=curlimages/curl:8.10.1 --restart=Never --command -- sleep 3600 >/dev/null
kubectl wait --for=condition=Ready pod/"$RUNNER" -n "$NS" --timeout=180s >/dev/null
cleanup() { kubectl delete pod "$RUNNER" -n "$NS" --ignore-not-found >/dev/null 2>&1 || true; }
trap cleanup EXIT

case_run() {
  local id="$1" category="$2" scenario="$3" expected="$4" method="$5" path="$6" headers="$7" body="${8:-}"
  local response code payload result
  response=$(kubectl exec -n "$NS" "$RUNNER" -- sh -c "curl -sS -X '$method' -w '\n%{http_code}' $headers --data-raw '$body' '$SERVICE$path'")
  code="${response##*$'\n'}"
  payload="${response%$'\n'*}"
  result=Fail; [[ "$code" == "$expected" ]] && result=Pass
  python3 - "$RAW" "$id" "$category" "$scenario" "$expected" "$code" "$result" "$payload" <<'PY'
import json, sys
out, ident, category, scenario, expected, actual, result, payload = sys.argv[1:]
with open(out, "a") as f:
    f.write(json.dumps({"id": ident, "category": category, "scenario": scenario,
                        "expected": int(expected), "actual": int(actual),
                        "result": result, "response": payload}) + "\n")
PY
}

BASE="-H 'x-demo-scope: accounts.read' -H 'x-demo-dpop: true' -H 'x-demo-mtls: true'"
PAY="-H 'content-type: application/json' -H 'x-demo-scope: payments.write' -H 'x-demo-dpop: true' -H 'x-demo-mtls: true'"

case_run S01 Spoofing "Missing proof rejected" 403 GET /v1/accounts "-H 'x-correlation-id: stride-s01' -H 'x-demo-scope: accounts.read' -H 'x-demo-mtls: true'"
case_run T01 Tampering "Proof HTTP method mismatch rejected" 403 GET /v1/accounts "$BASE -H 'x-correlation-id: stride-t01' -H 'x-demo-proof-method: POST'"
case_run T02 Tampering "Proof URI mismatch rejected" 403 GET /v1/accounts "$BASE -H 'x-correlation-id: stride-t02' -H 'x-demo-proof-uri: /v1/payments'"
case_run T03 Tampering "Post-signing body modification rejected" 403 POST /v1/payments "$PAY -H 'x-correlation-id: stride-t03' -H 'x-demo-proof-body-sha256: 0000000000000000000000000000000000000000000000000000000000000000'" '{"amount":999}'
case_run I01 "Information Disclosure" "Authorized response remains redacted" 200 GET /v1/accounts "$BASE -H 'x-correlation-id: stride-i01'"
case_run E01 "Elevation of Privilege" "Ordinary account scope denied on admin route" 403 GET /v1/admin/audit "$BASE -H 'x-correlation-id: stride-e01'"
case_run E02 "Elevation of Privilege" "Unknown workload denied on admin route" 403 GET /v1/admin/audit "-H 'x-correlation-id: stride-e02' -H 'x-demo-scope: admin.audit' -H 'x-demo-dpop: true' -H 'x-demo-mtls: true' -H 'x-demo-spiffe-id: spiffe://miva.local/ns/default/sa/unknown'"

sleep 2
kubectl logs -n "$NS" -l app=sample-financial-api --since=10m --prefix > "$OUT/api-audit-logs.txt"
for cid in stride-s01 stride-t01 stride-t02 stride-t03 stride-i01 stride-e01 stride-e02; do
  if grep -q "\"correlation_id\": \"$cid\"" "$OUT/api-audit-logs.txt"; then
    printf '{"id":"R-%s","category":"Repudiation","scenario":"correlated audit record present","expected":1,"actual":1,"result":"Pass","response":"%s"}\n' "$cid" "$cid" >> "$RAW"
  else
    printf '{"id":"R-%s","category":"Repudiation","scenario":"correlated audit record present","expected":1,"actual":0,"result":"Fail","response":"%s"}\n' "$cid" "$cid" >> "$RAW"
  fi
done

python3 - "$RAW" "$REPORT" <<'PY'
import json, pathlib, re, sys
raw, report = map(pathlib.Path, sys.argv[1:])
rows = [json.loads(x) for x in raw.read_text().splitlines() if x]
for row in rows:
    if row["category"] == "Information Disclosure":
        response = row["response"].lower()
        forbidden = ["client-key", "private key", "authorization:", "password", "token"]
        redacted = '"balance": "redacted"' in response
        if any(x in response for x in forbidden) or not redacted:
            row["result"] = "Fail"
raw.write_text("".join(json.dumps(x) + "\n" for x in rows))
passed = sum(x["result"] == "Pass" for x in rows)
with report.open("w") as f:
    f.write("# Live STRIDE Validation Results\n\n")
    f.write(f"Passed: {passed}/{len(rows)}\n\n")
    f.write("| ID | Category | Scenario | Expected | Actual | Result |\n|---|---|---|---:|---:|---|\n")
    for x in rows:
        f.write(f"| {x['id']} | {x['category']} | {x['scenario']} | {x['expected']} | {x['actual']} | {x['result']} |\n")
PY

if [[ "${STRIDE_LOAD_CONFIRMED:-}" == "true" ]]; then
  before=$(kubectl get deploy -n "$NS" sample-financial-api -o jsonpath='{.status.readyReplicas}')
  kubectl exec -n "$NS" "$RUNNER" -- sh -c "i=0; while [ \$i -lt 40 ]; do curl -fsS '$SERVICE/healthz' >/dev/null & i=\$((i+1)); done; wait"
  kubectl wait -n "$NS" --for=condition=Available deployment/sample-financial-api --timeout=120s >/dev/null
  after=$(kubectl get deploy -n "$NS" sample-financial-api -o jsonpath='{.status.readyReplicas}')
  code=$(kubectl exec -n "$NS" "$RUNNER" -- sh -c "curl -sS -o /dev/null -w '%{http_code}' '$SERVICE/healthz'")
  result=Fail; [[ "$before" -ge 1 && "$after" -ge 1 && "$code" == 200 ]] && result=Pass
  printf '{"id":"D01","category":"Denial of Service","scenario":"bounded 40-request burst and recovery","expected":200,"actual":%s,"result":"%s","response":"ready_before=%s ready_after=%s"}\n' "$code" "$result" "$before" "$after" >> "$RAW"
  python3 - "$RAW" "$REPORT" <<'PY'
import json, pathlib, sys
raw, report = map(pathlib.Path, sys.argv[1:]); rows=[json.loads(x) for x in raw.read_text().splitlines() if x]
passed=sum(x["result"]=="Pass" for x in rows)
with report.open("w") as f:
 f.write(f"# Live STRIDE Validation Results\n\nPassed: {passed}/{len(rows)}\n\n")
 f.write("| ID | Category | Scenario | Expected | Actual | Result |\n|---|---|---|---:|---:|---|\n")
 for x in rows: f.write(f"| {x['id']} | {x['category']} | {x['scenario']} | {x['expected']} | {x['actual']} | {x['result']} |\n")
PY
else
  echo "Bounded DoS case not run: set STRIDE_LOAD_CONFIRMED=true within the approved load window." > "$OUT/dos-not-run.txt"
fi

cat "$REPORT"
if grep -q '"result": "Fail"' "$RAW"; then exit 1; fi
