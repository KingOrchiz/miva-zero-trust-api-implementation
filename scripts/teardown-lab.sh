#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT/terraform/envs/lab"
ACTION="${1:-help}"
CONFIRMATION='destroy-dedicated-azure-and-huawei-lab'

usage() {
  cat <<EOF
Usage: scripts/teardown-lab.sh <plan|destroy|verify>

  plan     Refresh state and create a read-only destroy preview for both clouds.
  destroy  Queue the dual-cloud destroy after the exact confirmation gate.
  verify   Show remaining Terraform state and operator-side cloud checks.

Destroy gate:
  DESTROY_MIVA_CONFIRMED=$CONFIRMATION

Scope:
  Dedicated iRestrict Azure and Huawei lab resources managed by
  terraform/envs/lab. The existing Azure resource group is a data source and
  is not itself managed for deletion by this configuration.
EOF
}

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "STOP: missing command: $1" >&2; exit 2; }
}

init() {
  require terraform
  terraform -chdir="$TF_DIR" init -input=false >/dev/null
}

plan() {
  init
  echo 'READ-ONLY: refreshing live state and previewing destruction.'
  echo 'Review every resource. No cloud object is changed by this command.'
  terraform -chdir="$TF_DIR" plan -destroy -input=false
}

destroy() {
  [[ "${DESTROY_MIVA_CONFIRMED:-}" == "$CONFIRMATION" ]] || {
    echo "STOP: set DESTROY_MIVA_CONFIRMED=$CONFIRMATION only after reviewing a fresh destroy plan." >&2
    exit 2
  }
  init
  echo 'FINAL GATE: Terraform will regenerate the destroy plan.'
  echo 'Confirm only if it contains the approved dedicated Azure and Huawei lab resources.'
  terraform -chdir="$TF_DIR" destroy -input=true
}

verify() {
  init
  echo '--- Terraform state remaining ---'
  terraform -chdir="$TF_DIR" state list || true

  echo '--- Azure dedicated-lab resources still visible in Jane_Lab ---'
  if command -v az >/dev/null 2>&1; then
    az resource list --resource-group "${IRESTRICT_AZURE_RESOURCE_GROUP:-Jane_Lab}" \
      --query "[?contains(name, 'irestrict') || contains(name, 'iRestrict')].[name,type,location]" \
      -o table || true
  else
    echo 'Azure CLI not installed; verify Jane_Lab in the Azure portal.'
  fi

  cat <<'EOF'
--- Huawei verification ---
In AF-Johannesburg and the approved enterprise project, verify that the
iRestrict CCE cluster/node pool, VPC, subnet, NAT gateway, EIPs and LTS objects
are absent. Also check Billing > Cost Analysis for residual running resources.

After both clouds are clean, securely remove the temporary Azure/Huawei
kubeconfigs and Huawei client key from the operator workstation.
EOF
}

case "$ACTION" in
  plan) plan ;;
  destroy) destroy ;;
  verify) verify ;;
  help|-h|--help|'') usage ;;
  *) usage >&2; exit 2 ;;
esac
