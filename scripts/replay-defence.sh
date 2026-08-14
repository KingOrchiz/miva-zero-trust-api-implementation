#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-}"
RUN_ID="${2:-defence-${TARGET}-$(date -u +%Y%m%dT%H%M%SZ)}"

if [[ "$TARGET" != "azure" && "$TARGET" != "huawei" ]]; then
  echo "Usage: $0 <azure|huawei> [run-id]" >&2
  exit 2
fi
if [[ -z "${KUBECONFIG:-}" ]]; then
  echo "Set KUBECONFIG explicitly to the approved $TARGET credential." >&2
  exit 2
fi
if [[ "${REPLAY_MIVA_CONFIRMED:-}" != "true" ]]; then
  echo "Set REPLAY_MIVA_CONFIRMED=true after verifying the cloud account and context." >&2
  exit 2
fi

echo "Run ID: $RUN_ID"
echo "Target: $TARGET"
echo "Context: $(kubectl config current-context)"
kubectl get nodes -o wide

IRESTRICT_TARGET_CLOUD="$TARGET" DEPLOY_MIVA_CONFIRMED=true "$ROOT/scripts/deploy-k8s-manifests.sh"
"$ROOT/scripts/run-validation-tests.sh" "$RUN_ID"

if [[ ! -x "$ROOT/.venv/bin/python" ]]; then
  "$ROOT/scripts/bootstrap-python.sh"
fi
IRESTRICT_EVIDENCE_RUN_ID="${RUN_ID}-dpop" "$ROOT/.venv/bin/python" "$ROOT/scripts/dpop_crypto_validation.py"
IRESTRICT_EVIDENCE_RUN_ID="${RUN_ID}-requirements" "$ROOT/.venv/bin/python" "$ROOT/scripts/local_requirement_validation.py"

"$ROOT/scripts/collect-evidence.sh" "$RUN_ID"
echo "Replay completed. Evidence: $ROOT/evidence/$RUN_ID"
echo "Performance tests are intentionally separate; run them only within the approved load window."
