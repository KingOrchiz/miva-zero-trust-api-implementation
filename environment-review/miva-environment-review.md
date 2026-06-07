# MIVA Environment Review and Deployment Recommendation

Status: read-only review completed. No resources were created, modified, or deployed.

## Recommendation

- Deployment mode: `existing-clusters`.
- Azure primary target: `aks-staging` in `BANKONE-STAG-RSG`, eastus.
- Azure fallback target: `aks-test` in `BANKONE-RSG`, eastus.
- Huawei primary target: `cluster-staging` in `af-south-1`.
- Huawei fallback target: `bankone-test` in `af-south-1`.
- Exclude production clusters: Azure `aks-prod`, Huawei `cluster-prod`.
- Avoid Huawei `cluster-test` because it is currently hibernated.

## Why this is the safest route

- It uses existing non-production Kubernetes capacity instead of creating new cloud infrastructure.
- It reduces cost and deployment lead time for Chapter 4 evidence collection.
- It keeps the MIVA prototype isolated to namespaces and application-level components.
- It avoids production clusters and avoids resource creation until explicitly approved.

## Azure findings

| Cluster | Resource group | Location | Kubernetes | Power | Assessment |
|---|---|---|---|---|---|
| `aks-staging` | `BANKONE-STAG-RSG` | `eastus` | `1.36.0` | `Running` | Primary candidate |
| `aks-test` | `BANKONE-RSG` | `eastus` | `1.36.0` | `Running` | Fallback candidate |
| `aks-prod` | `BANKONE-RSG` | `eastus` | `1.33.12` | `Running` | Excluded, production-looking |

## Huawei findings

| Cluster | Region | Phase | VPC | Subnet | Assessment |
|---|---|---|---|---|---|
| `recova-test` | `af-south-1` | `Available` | `b32a142d-4a7d-41f4-a629-471ff07091a6` | `e72ea743-bb74-4cb2-b351-e31838adc24d` | Possible non-production candidate |
| `cluster-test` | `af-south-1` | `Hibernation` | `b32a142d-4a7d-41f4-a629-471ff07091a6` | `7a4179be-f22f-4f9d-844d-626eee967a0b` | Avoid, hibernated |
| `clustertest` | `af-south-1` | `Available` | `b32a142d-4a7d-41f4-a629-471ff07091a6` | `7a4179be-f22f-4f9d-844d-626eee967a0b` | Possible non-production candidate |
| `deployment-cluster` | `af-south-1` | `Available` | `b32a142d-4a7d-41f4-a629-471ff07091a6` | `5d6aa716-b812-4025-8230-fb4b41812e09` | Possible non-production candidate |
| `bankone-test` | `af-south-1` | `Available` | `b32a142d-4a7d-41f4-a629-471ff07091a6` | `88165328-88c8-4359-a11a-f6c0e48dd267` | Fallback candidate |
| `cluster-staging` | `af-south-1` | `Available` | `b32a142d-4a7d-41f4-a629-471ff07091a6` | `8f7e10f5-5a64-4114-9386-120e698dfcfb` | Primary candidate |
| `cluster-prod` | `af-south-1` | `Available` | `b32a142d-4a7d-41f4-a629-471ff07091a6` | `8a33699d-cd05-4eb6-9baa-a1872f63585c` | Excluded, production-looking |

## Proposed deployment boundary

- Create only MIVA namespaces: `miva-system`, `miva-identity`, `miva-security`, `miva-observability`, `miva-apps`.
- Deploy only prototype components: Keycloak, SPIRE/SPIFFE, OPA, OpenTelemetry, sample API, synthetic client, and test policies.
- Do not use real customer data.
- Do not make production-impacting changes.
- Do not run Terraform apply until Oche approves the final target and boundary.

## Approval needed before deployment

Please confirm:
1. Use Azure `aks-staging` and Huawei `cluster-staging`.
2. Namespace-only deployment boundary is acceptable.
3. Jane may fetch kubeconfigs for those clusters.
4. Supporting cost ceiling for ingress, registry, secrets, and logging.
