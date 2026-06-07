# MIVA Zero-Trust API Authentication Prototype

Deployable implementation workspace for the MIVA project: **Design and Implementation of a Zero-Trust, Asymmetric, and Identity-Bound API Authentication Framework for Financial Systems**.

## Purpose

This repository turns the academic Chapter 4 design into a repeatable prototype that can be deployed, tested, destroyed, and redeployed on demand.

## Current implementation status

Completed:
- GitHub repository created and connected.
- HCP Terraform organization and workspace created.
- Terraform Cloud workspace uses manual apply only.
- Terraform root module supports two deployment modes:
  - `existing-clusters`
  - `dedicated-lab`
- Azure and Huawei platform modules scaffolded.
- Kubernetes namespace, SPIRE, OPA, OpenTelemetry, sample API, and synthetic client manifests added.
- Evidence capture and validation scripts added.

Pending Oche confirmation:
- Azure target environment.
- Huawei Cloud target environment.
- Whether to deploy into existing dev/staging clusters or create dedicated lab clusters.
- Cloud credentials/variables in HCP Terraform.
- Approval before any `terraform apply` or Kubernetes deployment.

## Target environment

- Azure: AKS, Key Vault, Monitor or Log Analytics, container registry, public ingress option.
- Huawei Cloud: CCE, DEW or secrets service, Cloud Eye, Log Tank Service, ELB, DNS, container registry.
- Shared platform components: Keycloak, SPIRE/SPIFFE, Istio or Envoy, OPA, OpenTelemetry, sample APIs, synthetic clients, audit evidence pipeline.

## Deployment modes

### existing-clusters

Use existing non-production AKS and CCE clusters. Recommended if suitable dev/staging clusters exist.

### dedicated-lab

Terraform creates a dedicated lab foundation. Recommended if existing clusters are unsuitable or too risky.

## Safety principles

- No real customer data.
- No production deployment without explicit approval.
- Cost-aware lab sizing.
- Terraform first, manual changes avoided.
- Teardown must be available from day one.
- Secrets must not be committed.
- Every validation test must produce evidence for Chapter 4.

## Repository structure

```text
terraform/               HCP Terraform configuration and cloud modules
k8s/                     Kubernetes manifests for prototype components
scripts/                 Review, deploy, evidence, and validation scripts
docs/                    Architecture, implementation plan, and environment review
evidence/                Test evidence output, gitignored except templates
```

## Next workflow

1. Review Azure/Huawei dev and staging environments.
2. Select deployment target.
3. Add cloud variables in HCP Terraform.
4. Run Terraform plan.
5. Oche approves any apply.
6. Deploy Kubernetes manifests only to approved non-production context.
7. Run validation tests and collect Chapter 4 evidence.
