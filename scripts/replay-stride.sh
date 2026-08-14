#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"
RUN_ID="${2:-stride-${TARGET}-$(date -u +%Y%m%dT%H%M%SZ)}"

[[ "$TARGET" == "azure" || "$TARGET" == "huawei" ]] || { echo "Usage: $0 <azure|huawei> [run-id]" >&2; exit 2; }
[[ -n "${KUBECONFIG:-}" ]] || { echo "Set KUBECONFIG explicitly." >&2; exit 2; }
[[ "${STRIDE_MIVA_CONFIRMED:-}" == "true" ]] || { echo "Set STRIDE_MIVA_CONFIRMED=true after verifying the lab target." >&2; exit 2; }

echo "STRIDE run: $RUN_ID"
echo "Target: $TARGET"
echo "Context: $(kubectl config current-context)"
kubectl get nodes -o wide

IRESTRICT_TARGET_CLOUD="$TARGET" DEPLOY_MIVA_CONFIRMED=true "$ROOT/scripts/deploy-k8s-manifests.sh"
"$ROOT/scripts/run-validation-tests.sh" "$RUN_ID"

if [[ ! -x "$ROOT/.venv/bin/python" ]]; then "$ROOT/scripts/bootstrap-python.sh"; fi
IRESTRICT_EVIDENCE_RUN_ID="${RUN_ID}-dpop" "$ROOT/.venv/bin/python" "$ROOT/scripts/dpop_crypto_validation.py"
IRESTRICT_EVIDENCE_RUN_ID="${RUN_ID}-requirements" "$ROOT/.venv/bin/python" "$ROOT/scripts/local_requirement_validation.py"

STRIDE_MIVA_CONFIRMED=true STRIDE_LOAD_CONFIRMED="${STRIDE_LOAD_CONFIRMED:-false}" \
  "$ROOT/scripts/run-stride-tests.sh" "$RUN_ID"
"$ROOT/scripts/collect-evidence.sh" "$RUN_ID"

echo "STRIDE replay completed. Evidence: $ROOT/evidence/$RUN_ID"
echo "Verify with: (cd '$ROOT/evidence/$RUN_ID' && shasum -a 256 -c SHA256SUMS)"
