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
  echo "Collected UTC: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "Git commit: $(git -C "$ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"
  echo "Git tags: $(git -C "$ROOT" tag --points-at HEAD 2>/dev/null | paste -sd, - || true)"
  echo
  echo "## Kubernetes context"
  kubectl config current-context 2>/dev/null || true
  echo
  echo "## Evidence scope"
  echo "This evidence bundle captures the currently selected Kubernetes context, infrastructure outputs where available, workload health, service inventory, pod logs, and any validation-test outputs already present for the iRestrict Version 3 prototype. Interpret the bundle according to the active context and run ID, for example Azure AKS or Huawei CCE."
  echo
  echo "## Context note"
  echo "This script no longer assumes Huawei CCE is unreachable or that tests run only on AKS. If the active context is Huawei CCE, the collected Kubernetes inventory and logs are Huawei runtime evidence. If the active context is Azure AKS, they are Azure runtime evidence."
} > "$OUT/chapter4-evidence-summary.md"

if command -v terraform >/dev/null 2>&1; then
  (cd "$ROOT/terraform/envs/lab" && terraform version && terraform validate -no-color) > "$OUT/terraform-validate.txt" 2>&1 || true
  (cd "$ROOT/terraform/envs/lab" && terraform output -no-color) > "$OUT/terraform-outputs.txt" 2>&1 || true
  (cd "$ROOT/terraform/envs/lab" && terraform state list) > "$OUT/terraform-state-list.txt" 2>&1 || true
fi

if command -v kubectl >/dev/null 2>&1; then
  {
    echo "context=$(kubectl config current-context 2>/dev/null || true)"
    kubectl config view --minify -o jsonpath='cluster={.contexts[0].context.cluster}{"\n"}user={.contexts[0].context.user}{"\n"}server={.clusters[0].cluster.server}{"\n"}' 2>/dev/null || true
  } > "$OUT/kube-context-sanitized.txt"
  kubectl get nodes -o wide > "$OUT/nodes.txt" 2>&1 || true
  cp "$OUT/nodes.txt" "$OUT/aks-nodes.txt" 2>/dev/null || true
  kubectl get ns --show-labels > "$OUT/namespaces.txt" 2>&1 || true
  kubectl get pods -A -o wide > "$OUT/all-pods.txt" 2>&1 || true
  kubectl get svc -A -o wide > "$OUT/all-services.txt" 2>&1 || true
  kubectl get deploy -A -o wide > "$OUT/all-deployments.txt" 2>&1 || true
  kubectl get daemonset -A -o wide > "$OUT/all-daemonsets.txt" 2>&1 || true
  kubectl get statefulset -A -o wide > "$OUT/all-statefulsets.txt" 2>&1 || true
  kubectl get job -A -o wide > "$OUT/all-jobs.txt" 2>&1 || true
  kubectl get events -A --sort-by=.lastTimestamp > "$OUT/all-events.txt" 2>&1 || true
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

{
  echo "# Evidence secret scan"
  echo "Patterns: PEM private keys, kubeconfig client-key-data, bearer authorization headers"
  if grep -RInE 'BEGIN [A-Z ]*PRIVATE KEY|client-key-data[[:space:]]*:|Authorization:[[:space:]]*Bearer' "$OUT" --exclude=SHA256SUMS --exclude=evidence-secret-scan.txt; then
    echo "Result: FAIL"
    exit 1
  else
    echo "Result: PASS"
  fi
} > "$OUT/evidence-secret-scan.txt"

{
  echo "# SHA-256 evidence manifest"
  find "$OUT" -maxdepth 1 -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum
} > "$OUT/SHA256SUMS"

echo "Evidence collected under $OUT"
