# MIVA Implementation Plan

## Phase 0: Access and repository setup

Required decisions:
- Azure subscription to use.
- Huawei Cloud project/region to use.
- GitHub repository name and visibility.
- Whether GitHub Actions may deploy to cloud or only run Terraform plan.

Required credentials:
- Azure service principal with least privilege for lab resource groups.
- Huawei Cloud IAM access key with least privilege for CCE, VPC, ELB, DEW/secrets, logging, and monitoring.
- GitHub secrets for CI/CD only after approval.

## Phase 1: Infrastructure foundation

Deploy using Terraform:
- Azure resource group, VNet, AKS, Key Vault, Log Analytics, container registry.
- Huawei VPC, CCE cluster, ELB, DEW/secrets integration, Cloud Eye, Log Tank Service, container registry.
- Common tags and naming convention.
- Destroy path and cost controls.

## Phase 2: Platform security components

Deploy using Helm or Kubernetes manifests:
- Keycloak realm and clients.
- SPIRE server and agents.
- Istio or Envoy service mesh with mTLS.
- OPA policies.
- OpenTelemetry collector and log export.

## Phase 3: Application prototype

Deploy:
- Sample financial API.
- API gateway or ingress enforcement point.
- Synthetic client with DPoP key pair.
- Service-to-service workload identity test flow.

## Phase 4: Validation scenarios

Run tests for:
- Valid DPoP request.
- Stolen token without DPoP proof.
- Invalid DPoP signature.
- Wrong mTLS client identity.
- Wrong SPIFFE workload identity.
- OPA policy denial.
- Latency baseline versus secured request path.
- Audit evidence completeness.

## Phase 5: Evidence and dissertation update

Capture:
- Terraform outputs.
- Screenshots.
- Test logs.
- OPA decision logs.
- OpenTelemetry traces.
- Performance tables.
- Chapter 4 evidence mapping.
