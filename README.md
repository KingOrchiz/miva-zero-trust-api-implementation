# MIVA Zero-Trust API Authentication Prototype

Deployable implementation workspace for the MIVA project: **Design and Implementation of a Zero-Trust, Asymmetric, and Identity-Bound API Authentication Framework for Financial Systems**.

## Purpose

This repository is intended to turn the academic design into a repeatable lab prototype that can be deployed, tested, destroyed, and redeployed on demand.

## Target environment

- Azure: AKS, Key Vault, Monitor or Log Analytics, container registry, public ingress option.
- Huawei Cloud: CCE, DEW or secrets service, Cloud Eye, Log Tank Service, ELB, DNS, container registry.
- Shared platform components: Keycloak, SPIRE/SPIFFE, Istio or Envoy, OPA, OpenTelemetry, sample APIs, synthetic clients, audit evidence pipeline.

## Implementation principles

- No real customer data.
- Cost-aware lab sizing.
- Terraform first, manual changes avoided.
- Teardown must be available from day one.
- Secrets must not be committed.
- Every validation test must produce evidence for Chapter 4.

## Proposed workflow

1. Configure cloud credentials locally or through GitHub Actions secrets.
2. Run Terraform plan for the lab environment.
3. Deploy Azure and Huawei Kubernetes foundations.
4. Install shared security components.
5. Deploy sample financial APIs and clients.
6. Run validation scenarios.
7. Export evidence into `evidence/` for the dissertation and defense deck.
8. Destroy lab resources when not in use.

## Current status

Initial local scaffold created. Cloud access and repository publication are pending explicit approval.
