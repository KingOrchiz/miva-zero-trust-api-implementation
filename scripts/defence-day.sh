#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTION="${1:-help}"
TARGET="${2:-}"
RUN_ID="${3:-defence-${TARGET}-$(date -u +%Y%m%dT%H%M%SZ)}"

usage() {
  cat <<'EOF'
Usage: scripts/defence-day.sh <preflight|deploy|validate|standard|full> <azure|huawei> [run-id]

Required:
  KUBECONFIG=/absolute/path/to/approved-kubeconfig

Mutation gates:
  DEFENCE_DEPLOY_CONFIRMED=true   deploy/validate/full
  DEFENCE_LOAD_CONFIRMED=true     standard/full

This script never runs Terraform apply or destroy. Infrastructure recreation and teardown
remain separate, manually approved HCP Terraform operations.
EOF
}

[[ "$ACTION" != "help" ]] || { usage; exit 0; }
[[ "$TARGET" == "azure" || "$TARGET" == "huawei" ]] || { usage >&2; exit 2; }
[[ -n "${KUBECONFIG:-}" && "$KUBECONFIG" = /* && -s "$KUBECONFIG" ]] || {
  echo "Set KUBECONFIG to an existing absolute-path credential for $TARGET." >&2; exit 2;
}

expected_context_regex=''
case "$TARGET" in
  azure) expected_context_regex='irestrict-azure|aks-irestrict-v3-lab' ;;
  huawei) expected_context_regex='external|cce-irestrict-v3-lab|irestrict-huawei' ;;
esac

preflight() {
  local context ready total
  context="$(kubectl config current-context)"
  [[ "$context" =~ $expected_context_regex ]] || {
    echo "STOP: context '$context' does not match approved $TARGET lab." >&2; exit 1;
  }
  kubectl cluster-info >/dev/null
  total="$(kubectl get nodes --no-headers | wc -l | tr -d ' ')"
  ready="$(kubectl get nodes --no-headers | awk '$2=="Ready" {n++} END {print n+0}')"
  [[ "$total" -ge 2 && "$ready" -eq "$total" ]] || {
    kubectl get nodes -o wide; echo "STOP: expected at least two Ready nodes." >&2; exit 1;
  }
  echo "Preflight passed: target=$TARGET context=$context nodes=$ready/$total Ready"
  git -C "$ROOT" rev-parse --short HEAD
  kubectl get nodes -o wide
}

deploy() {
  [[ "${DEFENCE_DEPLOY_CONFIRMED:-}" == "true" ]] || {
    echo "Set DEFENCE_DEPLOY_CONFIRMED=true after verifying the target." >&2; exit 2;
  }
  IRESTRICT_TARGET_CLOUD="$TARGET" DEPLOY_MIVA_CONFIRMED=true \
    "$ROOT/scripts/deploy-k8s-manifests.sh"
}

validate() {
  [[ "${DEFENCE_DEPLOY_CONFIRMED:-}" == "true" ]] || {
    echo "Set DEFENCE_DEPLOY_CONFIRMED=true after verifying the target." >&2; exit 2;
  }
  STRIDE_MIVA_CONFIRMED=true STRIDE_LOAD_CONFIRMED=true \
    "$ROOT/scripts/replay-stride.sh" "$TARGET" "$RUN_ID"
}

standard() {
  [[ "${DEFENCE_LOAD_CONFIRMED:-}" == "true" ]] || {
    echo "Set DEFENCE_LOAD_CONFIRMED=true for the approved 300-RPS window." >&2; exit 2;
  }
  K6_RATE=300 K6_DURATION=60s \
    "$ROOT/scripts/run-k6-standard.sh" "standard-${TARGET}-${RUN_ID}"
}

case "$ACTION" in
  preflight) preflight ;;
  deploy) preflight; deploy ;;
  validate) preflight; validate ;;
  standard) preflight; standard ;;
  full) preflight; deploy; validate; standard ;;
  *) usage >&2; exit 2 ;;
esac

echo "Defence-day action complete: action=$ACTION target=$TARGET run_id=$RUN_ID"
