# Access Required

No cloud resources should be created until Oche explicitly confirms the target accounts and deployment boundary.

## Azure

Needed:
- Subscription ID
- Tenant ID
- Resource group naming preference
- Region preference
- Service principal or approval to create one

Recommended minimum scope:
- Contributor on a dedicated MIVA lab resource group only
- Key Vault Secrets Officer if Key Vault secrets are managed separately

## Huawei Cloud

Needed:
- Account/project name
- Region
- Enterprise project ID if used
- IAM access key or approval to create a dedicated IAM user

Recommended minimum scope:
- Permissions limited to dedicated MIVA lab resources for VPC, CCE, ELB, DEW/secrets, monitoring, logging, and registry.

## GitHub

Needed:
- Repository name
- Visibility: private recommended
- Whether Jane may create the repository
- Whether GitHub Actions may run `terraform apply`, or only `terraform plan`

## Cost controls

Recommended:
- Smallest available cluster/node sizes
- Strict tags
- Manual approval before apply
- Default destroy job or explicit teardown command after testing
