# Dev and Staging Environment Review for MIVA Chapter 4

## Purpose

Before deploying the MIVA prototype into any existing Azure or Huawei Cloud environment, we must confirm that the target environment is suitable, low-risk, and clearly separated from production workloads.

## Recommended deployment target

Preferred: dedicated **dev** or **staging** environment with no customer data and no production dependencies.

Avoid:
- Production subscriptions/projects
- Shared clusters with sensitive workloads
- Environments without teardown permission
- Environments where service mesh, ingress, or policy changes could impact existing apps

## Azure review checklist

Collect the following before deployment:

- Tenant ID
- Subscription ID
- Candidate resource group names
- Candidate AKS cluster names, if reusing existing AKS
- Region
- Permission boundary for the MIVA deployment
- Whether Azure Key Vault is available
- Whether Log Analytics/Azure Monitor is available
- Whether container registry is available
- Whether public ingress is allowed in dev/staging
- Network restrictions, private cluster requirements, or firewall constraints

Recommended Azure target:

- Existing non-production AKS cluster, or
- Dedicated small AKS cluster created by Terraform in a MIVA lab resource group

## Huawei Cloud review checklist

Collect the following before deployment:

- Account/project name
- Enterprise project ID, if used
- Region
- Candidate CCE cluster names, if reusing existing CCE
- VPC/subnet details
- ELB availability
- DEW or secrets service availability
- Cloud Eye and Log Tank Service availability
- Container registry availability
- Public ingress constraints

Recommended Huawei target:

- Existing non-production CCE cluster, or
- Dedicated small CCE cluster created by Terraform in a MIVA lab project

## Deployment modes

### Mode A: dedicated lab environment

Terraform creates the required cloud resources, including Kubernetes clusters.

Best for:
- Clean research evidence
- Repeatability
- Controlled teardown

Risk:
- Higher cost than reusing existing clusters

### Mode B: existing dev/staging clusters

Terraform or scripts deploy only Kubernetes-level components into pre-existing AKS/CCE clusters.

Best for:
- Lower cost
- Faster implementation if clusters already exist

Risk:
- Must confirm no conflict with existing workloads, ingress, mesh, namespaces, or policies

## Recommendation

Start with **Mode B** if suitable dev/staging AKS and CCE clusters already exist and can be isolated by namespaces.

Use namespaces:
- `miva-system`
- `miva-identity`
- `miva-security`
- `miva-observability`
- `miva-apps`

If existing clusters are unsuitable, use Mode A with small dedicated clusters and strict teardown controls.
