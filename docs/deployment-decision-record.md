# Deployment Decision Record

Status: pending Oche confirmation

## Decision needed

Choose one implementation path for Chapter 4.

## Option 1: dedicated Azure and Huawei lab

Terraform creates new cloud infrastructure.

Pros:
- Clean repeatability
- Strong dissertation evidence
- No dependency on existing dev/staging workloads

Cons:
- Higher cost
- Requires cloud credentials and quota

## Option 2: existing dev/staging AKS and CCE

Deploy into existing non-production clusters using dedicated namespaces.

Pros:
- Lower cost
- Faster if environments are ready

Cons:
- Need careful review to avoid disrupting existing workloads
- Evidence may include environmental noise

## Recommendation

Use Option 2 if suitable isolated dev/staging clusters exist. Otherwise use Option 1 with small dedicated clusters.

## Confirmation needed from Oche

- Azure target environment
- Huawei target environment
- Approved deployment mode
- Cost ceiling
- Whether public ingress is allowed
- Whether GitHub Actions can run Terraform plan only or apply with manual approval
