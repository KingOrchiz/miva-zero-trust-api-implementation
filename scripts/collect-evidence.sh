#!/usr/bin/env bash
set -euo pipefail

RUN_ID="${1:-$(date +%F-%H%M%S)}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT/evidence/$RUN_ID"
mkdir -p "$OUT"

{
  echo "# MIVA Chapter 4 Evidence Summary"
  echo
  echo "Run ID: $RUN_ID"
  echo "Collected: $(date -Is)"
  echo
  echo "## Kubernetes context"
  kubectl config current-context 2>/dev/null || true
} > "$OUT/chapter4-evidence-summary.md"

if command -v terraform >/dev/null 2>&1; then
  (cd "$ROOT/terraform/envs/lab" && terraform version && terraform validate) > "$OUT/terraform-validate.txt" 2>&1 || true
fi

if command -v kubectl >/dev/null 2>&1; then
  kubectl get ns > "$OUT/namespaces.txt" 2>&1 || true
  kubectl get pods -A -l app.kubernetes.io/part-of=miva-zt-api-auth > "$OUT/miva-pods.txt" 2>&1 || true
  kubectl get pods -n miva-security -o wide > "$OUT/security-pods.txt" 2>&1 || true
  kubectl get pods -n miva-observability -o wide > "$OUT/observability-pods.txt" 2>&1 || true
  kubectl get pods -n miva-apps -o wide > "$OUT/app-pods.txt" 2>&1 || true
  kubectl logs -n miva-observability deploy/otel-collector --tail=200 > "$OUT/otel-collector-logs.txt" 2>&1 || true
fi

echo "Evidence collected under $OUT"
