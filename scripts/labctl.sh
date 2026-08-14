#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT_DIR/terraform/envs/lab"

usage() {
  cat <<'USAGE'
Usage: ./scripts/labctl.sh <command>

Commands:
  validate      Run Terraform format check and validation locally
  status        Show local CLI/auth/workspace status without changing cloud resources
  plan          Queue or run Terraform plan for the dedicated lab workspace
  plan-azure    Preview Azure module changes only (exceptional scoped review)
  plan-huawei   Preview Huawei module changes only (exceptional scoped review)
  refresh-plan  Refresh-only drift review; never changes remote objects
  destroy-plan  Create a Terraform destroy plan for review only

Safety:
  Dedicated lab only. Existing enterprise/dev/staging clusters are out of scope.
  This helper does not run terraform apply or terraform destroy directly.
  HCP Terraform manual approval remains the required apply/destroy gate.
USAGE
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing: $1" >&2
    return 1
  fi
}

terraform_init_if_needed() {
  cd "$TF_DIR"
  terraform init -input=false >/dev/null
}

cmd_validate() {
  require_cmd terraform
  terraform_init_if_needed
  cd "$TF_DIR"
  terraform fmt -check -recursive ..
  terraform validate
}

cmd_status() {
  echo "Repository: $ROOT_DIR"
  echo "Terraform dir: $TF_DIR"
  echo

  if command -v terraform >/dev/null 2>&1; then
    echo "Terraform: $(terraform version -json 2>/dev/null | python3 -c 'import sys,json; print(json.load(sys.stdin).get("terraform_version", "unknown"))' 2>/dev/null || terraform version | head -1)"
  else
    echo "Terraform: missing"
  fi

  if command -v az >/dev/null 2>&1; then
    echo "Azure CLI: installed"
    az account show --query '{tenantId:tenantId, subscriptionId:id, subscriptionName:name, user:user.name}' -o table 2>/dev/null || echo "Azure CLI: not logged in or no active subscription"
    echo
    echo "Expected Azure dedicated lab RG: ${IRESTRICT_AZURE_RESOURCE_GROUP:-Jane_Lab}"
    az group show -n "${IRESTRICT_AZURE_RESOURCE_GROUP:-Jane_Lab}" --query '{name:name, location:location, id:id}' -o table 2>/dev/null || echo "Azure RG visibility: not visible to current credentials, or RG name/subscription differs"
  else
    echo "Azure CLI: missing"
  fi

  if command -v kubectl >/dev/null 2>&1; then
    echo
    echo "kubectl current context: $(kubectl config current-context 2>/dev/null || echo none)"
  else
    echo "kubectl: missing"
  fi

  echo
  echo "HCP Terraform workspace: oche-miva / miva-zero-trust-api-lab"
  echo "Deployment mode: dedicated-lab only"
  echo "Dedicated lab tfvars template: dedicated-lab-irestrict-v3.tfvars.example"
}

cmd_plan() {
  require_cmd terraform
  terraform_init_if_needed
  cd "$TF_DIR"
  terraform plan -input=false
}

cmd_target_plan() {
  local cloud="$1"
  require_cmd terraform
  terraform_init_if_needed
  cd "$TF_DIR"
  echo "WARNING: targeted plans are for incident recovery/scoped diagnosis only."
  terraform plan -input=false -target="module.${cloud}_platform[0]"
}

cmd_refresh_plan() {
  require_cmd terraform
  terraform_init_if_needed
  cd "$TF_DIR"
  terraform plan -refresh-only -input=false
}

cmd_destroy_plan() {
  require_cmd terraform
  terraform_init_if_needed
  cd "$TF_DIR"
  terraform plan -destroy -input=false
}

case "${1:-}" in
  validate) cmd_validate ;;
  status) cmd_status ;;
  plan) cmd_plan ;;
  plan-azure) cmd_target_plan azure ;;
  plan-huawei) cmd_target_plan huawei ;;
  refresh-plan) cmd_refresh_plan ;;
  destroy-plan) cmd_destroy_plan ;;
  -h|--help|help|"") usage ;;
  *) echo "Unknown command: $1" >&2; usage; exit 2 ;;
esac
