# iRestrict Laboratory Prototype

Reproducible implementation workspace for **Design and Implementation of a Zero-Trust, Asymmetric, and Identity-Bound API Authentication Framework for Financial Systems**.

The academic artefact is called **iRestrict**. Historical resource and directory identifiers retain `irestrict-v3` where renaming would break Terraform state, Kubernetes references, or evidence paths.

## What this repository demonstrates

- Dedicated Azure AKS and Huawei CCE laboratory infrastructure managed by Terraform.
- Kubernetes deployments for Keycloak, SPIRE, OPA, OpenTelemetry, a sample financial API, and synthetic clients.
- T00-T07 policy-path validation on both clouds.
- Supplementary RFC 9449 DPoP cryptographic validation and local requirement harnesses.
- Matched baseline-versus-OPA policy-path benchmarks and an offered-load capacity ladder.

The cloud validation uses controlled DPoP-, mTLS-, and SPIFFE-style inputs. It does **not** claim production certificate-bound mTLS, cloud-gateway DPoP verification, cross-domain SPIFFE federation, hardware-backed keys, immutable audit storage, or regulatory certification.

## Verified 11 August 2026 state

- Deployment mode: `dedicated-lab` only.
- Azure target: approved `Jane_Lab` resource group in East US; one `Standard_B2s` AKS node at test time.
- Huawei target: approved enterprise project in `af-south-1`; two `s6.large.2` CCE nodes at test time.
- Terraform deployment: 17 resources added, with no pre-existing resources changed or destroyed.
- T00-T07: 8/8 passed on Azure and 8/8 on Huawei.
- The 30 ms P95 policy-path target was not met on Azure; it was met only in the bounded Huawei comparison.
- The 10,000 TPS target was not achieved by either lean laboratory.
- The laboratory remains billable until an approved destroy is completed.

See [Issue 6 evidence](evidence/issue6-performance-summary-20260811.md) for measured values and limitations.

## Repository structure

```text
terraform/   HCP Terraform configuration and cloud modules
k8s/         Kubernetes manifests for laboratory components
scripts/     validation, benchmark, evidence and safety helpers
docs/        deployment and self-replay runbooks
evidence/    dated raw outputs and derived summaries
```

## Safe replay sequence

1. Read [the self-run guide](docs/self-run-login-and-test-guide.md).
2. Confirm the intended cloud account and dedicated-lab boundary.
3. Run `./scripts/labctl.sh validate` and `./scripts/labctl.sh status`.
4. Review `./scripts/labctl.sh plan`; apply only through the approved HCP Terraform gate.
5. Select and verify the intended Kubernetes context.
6. Deploy manifests with `IRESTRICT_TARGET_CLOUD=<azure|huawei> DEPLOY_MIVA_CONFIRMED=true ./scripts/deploy-k8s-manifests.sh` and an explicit kubeconfig.
7. Run T00-T07 and collect evidence.
8. Run matched performance trials in alternating order, then the capacity ladder.
9. Preserve raw evidence and generate a destroy plan.
10. Destroy only after explicit approval.

For a guarded workload-to-evidence replay after infrastructure and credentials are ready:

```bash
export KUBECONFIG=/protected/path/to/the-approved-kubeconfig
REPLAY_MIVA_CONFIRMED=true ./scripts/replay-defence.sh huawei
```

See [credential lifecycle](docs/credential-lifecycle.md) and [STRIDE test plan](docs/stride-test-plan.md).

## Minimum validation commands

```bash
./scripts/labctl.sh validate
kubectl config current-context
RUN_ID="manual-$(date +%F-%H%M%S)"
./scripts/run-validation-tests.sh "$RUN_ID"
./scripts/collect-evidence.sh "$RUN_ID"

K6_VUS=50 K6_DURATION=15s K6_BASELINE_START=0s K6_SECURED_START=20s \
  ./scripts/run-k6-benchmark.sh "${RUN_ID}-baseline-first"
K6_VUS=50 K6_DURATION=15s K6_BASELINE_START=20s K6_SECURED_START=0s \
  ./scripts/run-k6-benchmark.sh "${RUN_ID}-secured-first"
./scripts/run-k6-capacity.sh "${RUN_ID}-capacity"
```

## Safety and evidence rules

- Never use production systems or customer data.
- Confirm `kubectl config current-context` before every deployment or test.
- Store secrets only in approved secret stores or sensitive HCP Terraform variables.
- Do not commit kubeconfigs, private keys, `.tfvars`, state files, tokens, or credentials.
- Preserve the raw log, generated job manifest, cluster/node inventory, tool versions, test order, and timestamps for every run.
- Treat the baseline endpoint bypass as a laboratory benchmark control, never as a production mode.
- Do not present controlled proof headers as full cryptographic enforcement.
- Do not export Huawei operational kubeconfigs from Terraform state; use newly issued CCE credentials.
- Use [the STRIDE test plan](docs/stride-test-plan.md) to distinguish tested controls from untested or target-design claims.

## 14 August 2026 operational recovery note

The Huawei CCE cluster and node pool were recovered after an out-of-band deletion. The existing VPC, subnet, NAT and EIP were reused; Azure was not changed. Fresh Huawei-issued credentials authenticated successfully, both CCE nodes became Ready, workloads were restored, and the recovery smoke job passed T00-T02. This does not replace the historical 11 August T00-T07 8/8 evidence; a fresh full matrix must be collected before making an equivalent new claim.

## Teardown

```bash
./scripts/labctl.sh destroy-plan
```

Review the exact targets and resource count before approving destroy in HCP Terraform. The helper deliberately does not execute apply or destroy itself.
