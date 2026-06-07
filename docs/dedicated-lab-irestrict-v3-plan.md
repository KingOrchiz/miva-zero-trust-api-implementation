# iRestrict Version 3 Dedicated Lab Plan

## Decision

Use a clean, dedicated lab instead of shared staging clusters. The implementation name is **iRestrict Version 3**.

## Target cloud layout

### Azure

- Region: `eastus`
- Resource group: `rg-irestrict-v3-lab`
- VNet: `vnet-irestrict-v3-lab`
- AKS subnet: `snet-aks-irestrict-v3-lab`
- AKS cluster: `aks-irestrict-v3-lab`
- Azure Container Registry: Basic SKU
- Key Vault: Standard SKU
- Log Analytics: 30-day retention
- AKS nodes: 1 x `Standard_B2s`, autoscale 1 to 2

### Huawei Cloud

- Region: `af-south-1`
- VPC: `vpc-irestrict-v3-lab`
- Subnet: `subnet-cce-irestrict-v3-lab`
- CCE cluster: `cce-irestrict-v3-lab`
- SWR organization for images
- LTS log group and stream, 30-day retention
- CCE nodes: 1 lean worker node, default candidate `s6.large.2`

## Cost posture

The design is intentionally lean:

- One worker node per cloud by default.
- Free/Basic/Standard low-cost SKUs where practical.
- 30-day logging retention.
- No production data.
- No production routing.
- Teardown remains mandatory after evidence collection.

## HCP Terraform deployment model

GitHub and HCP Terraform can be linked to a Gmail account. The email identity does not determine cloud access. Cloud deployment works if HCP Terraform has valid credentials for Azure and Huawei.

Recommended flow:

1. GitHub repo stores Terraform code.
2. HCP Terraform watches GitHub and runs plans from `terraform/envs/lab`.
3. HCP Terraform executes against Azure and Huawei using workspace variables.
4. Auto-apply remains disabled.
5. Oche reviews the plan.
6. Apply is approved manually only after the plan is acceptable.

## Required credentials and permissions

### Azure

Create or use an Azure service principal with contributor-level access limited to the target subscription or dedicated resource group scope.

Required HCP Terraform environment variables:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET` sensitive
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

Minimum practical permissions:

- Create/manage resource groups or a pre-approved resource group.
- Create/manage VNet, subnet, AKS, ACR, Key Vault, Log Analytics, managed identities, and role assignments if ACR pull is wired later.

Preferred safer scope:

- Contributor on a dedicated lab subscription, or Contributor on a pre-created resource group plus Network Contributor if VNet is outside that group.

### Huawei Cloud

Create or use a Huawei IAM user/access key with least privilege in the selected project/region.

Required HCP Terraform environment variables:

- `HW_ACCESS_KEY` sensitive
- `HW_SECRET_KEY` sensitive
- `HW_REGION_NAME` or Terraform variable `huawei_region`

Required practical permissions:

- VPC and subnet create/manage.
- CCE cluster and node pool create/manage.
- ECS node creation through CCE.
- EVS disks for CCE nodes.
- SWR organization/repository access.
- LTS log group/stream create/manage.
- IAM agency permissions if Huawei CCE requires them in the selected project.

Also required before apply:

- Confirm an existing Huawei ECS key pair name for `huawei_node_key_pair`.
- Confirm `cce.s1.small` and `s6.large.2` are available in `af-south-1`.
- Confirm quota for one CCE cluster, one worker node, EVS volumes, and any required load balancer.

## What not to do yet

- Do not enable `enable_kubernetes_bootstrap` yet.
- Do not fetch kubeconfigs yet.
- Do not deploy Keycloak, SPIRE, OPA, OpenTelemetry, or sample services yet.
- Do not apply until plan output and cost posture are approved.

## Immediate next step

Configure non-secret HCP Terraform variables first, then add sensitive cloud credentials. Run a remote Terraform plan only. Review the plan before any apply.
