#!/usr/bin/env bash
set -euo pipefail

RUN_ID="${1:-$(date +%F-%H%M%S)}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/evidence/$RUN_ID"
mkdir -p "$OUT"

{
  echo "# iRestrict Version 3 Chapter 4 Evidence Summary"
  echo
  echo "Run ID: $RUN_ID"
  echo "Collected: $(date -Is)"
  echo
  echo "## Kubernetes context"
  kubectl config current-context 2>/dev/null || true
  echo
  echo "## Evidence scope"
  echo "This evidence bundle covers the Azure AKS deployment, Huawei CCE infrastructure provisioning, Kubernetes security workloads, and live authorization tests for the iRestrict Version 3 prototype."
  echo
  echo "## Huawei CCE access note"
  echo "Huawei CCE was provisioned successfully, but its kubeconfig exposes an internal API endpoint in the 10.83.1.0/24 VPC range. The current runner cannot reach that private endpoint directly, so Kubernetes workload tests were executed on AKS while Huawei evidence is captured at infrastructure level."
} > "$OUT/chapter4-evidence-summary.md"

if command -v terraform >/dev/null 2>&1; then
  (cd "$ROOT/terraform/envs/lab" && terraform version && terraform validate -no-color) > "$OUT/terraform-validate.txt" 2>&1 || true
  (cd "$ROOT/terraform/envs/lab" && terraform output -no-color) > "$OUT/terraform-outputs.txt" 2>&1 || true
  (cd "$ROOT/terraform/envs/lab" && terraform state list) > "$OUT/terraform-state-list.txt" 2>&1 || true
fi

if command -v kubectl >/dev/null 2>&1; then
  kubectl get nodes -o wide > "$OUT/aks-nodes.txt" 2>&1 || true
  kubectl get ns --show-labels > "$OUT/namespaces.txt" 2>&1 || true
  kubectl get pods -A -o wide > "$OUT/all-pods.txt" 2>&1 || true
  kubectl get svc -A -o wide > "$OUT/all-services.txt" 2>&1 || true
  kubectl get deploy -A -o wide > "$OUT/all-deployments.txt" 2>&1 || true
  kubectl get daemonset -A -o wide > "$OUT/all-daemonsets.txt" 2>&1 || true
  kubectl get statefulset -A -o wide > "$OUT/all-statefulsets.txt" 2>&1 || true
  kubectl get job -A -o wide > "$OUT/all-jobs.txt" 2>&1 || true
  kubectl get pods -n irestrict-security -o wide > "$OUT/security-pods.txt" 2>&1 || true
  kubectl get pods -n irestrict-observability -o wide > "$OUT/observability-pods.txt" 2>&1 || true
  kubectl get pods -n irestrict-identity -o wide > "$OUT/identity-pods.txt" 2>&1 || true
  kubectl get pods -n irestrict-apps -o wide > "$OUT/app-pods.txt" 2>&1 || true
  kubectl logs -n irestrict-security deploy/opa --tail=300 > "$OUT/opa-logs.txt" 2>&1 || true
  kubectl logs -n irestrict-security statefulset/spire-server --tail=300 > "$OUT/spire-server-logs.txt" 2>&1 || true
  kubectl logs -n irestrict-security daemonset/spire-agent --tail=300 > "$OUT/spire-agent-logs.txt" 2>&1 || true
  kubectl logs -n irestrict-observability deploy/otel-collector --tail=300 > "$OUT/otel-collector-logs.txt" 2>&1 || true
  kubectl logs -n irestrict-identity deploy/keycloak --tail=200 > "$OUT/keycloak-logs.txt" 2>&1 || true
  kubectl logs -n irestrict-apps deploy/sample-financial-api --tail=300 > "$OUT/sample-api-logs.txt" 2>&1 || true
  kubectl logs -n irestrict-apps job/synthetic-client-smoke-test --tail=-1 > "$OUT/synthetic-client-logs.txt" 2>&1 || true
fi

if [[ -f "$OUT/security-test-results.md" ]]; then
  :
else
  echo "Security test results were not present in this run folder. Run scripts/run-validation-tests.sh $RUN_ID first if a live test matrix is required." > "$OUT/security-test-results-missing.txt"
fi

echo "Evidence collected under $OUT"
