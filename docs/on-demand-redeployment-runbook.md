# iRestrict On-Demand Redeployment Runbook

## Boundary

- Dedicated Azure and Huawei lab only.
- Terraform is the infrastructure source of truth.
- No production systems or customer data.
- Apply and destroy require explicit approval through the HCP Terraform manual gate.
- The Kubernetes baseline bypass exists only for matched laboratory measurement.

## Verified target pattern

- HCP Terraform: `oche-miva / miva-zero-trust-api-lab`
- Mode: `dedicated-lab`
- Azure: existing approved resource group `Jane_Lab`; Terraform-managed AKS and supporting services
- Huawei: approved enterprise project in `af-south-1`; Terraform-managed VPC, CCE, node pool, NAT/EIP and logging
- Kubernetes: repository manifests applied after each cluster context is verified

Cloud account identifiers and credentials belong in the private operator handoff or sensitive workspace variables, not this repository.

## Clean deployment sequence

```bash
./scripts/labctl.sh validate
./scripts/labctl.sh status
./scripts/labctl.sh plan
```

Review the plan for the intended subscription, `Jane_Lab`, approved Huawei enterprise project, lean node sizes, and no changes to pre-existing enterprise resources. Approve apply only after the plan is accepted.

After apply:

1. Acquire AKS and CCE kubeconfigs using the self-run guide.
2. Verify `kubectl config current-context` and `kubectl get nodes`.
3. Run `IRESTRICT_TARGET_CLOUD=<azure|huawei> DEPLOY_MIVA_CONFIRMED=true ./scripts/deploy-k8s-manifests.sh` with the cloud's kubeconfig explicitly selected.
4. Wait for the sample API and OPA deployments and SPIRE workloads.
5. Run T00-T07, evidence collection, two alternating matched trials and the capacity ladder.
6. Preserve the raw output before any teardown.

## Reproducibility rule

A run is reproducible only when its evidence directory contains the environment inventory, exact command, generated manifest/script, raw output, derived result, timestamp and limitations. Screenshots alone are supporting material, not the primary result.

## Destroy sequence

```bash
./scripts/labctl.sh destroy-plan
```

Verify that the plan targets only the dedicated lab resources. Approve destroy through HCP Terraform only after evidence preservation and explicit teardown approval.

## Failure handling

- Wrong cloud account/context: stop; do not continue.
- Unexpected replacement/deletion in plan: reject the run and investigate state/variables.
- CCE authentication failure after replacement: obtain a newly issued external-access YAML and `client.key` from Huawei CCE; never reuse Terraform's cached kubeconfig.
- Pod/image failure: record the event and retry only after capturing logs and events.
- Benchmark timeout/saturation: preserve the raw log and report the limitation; do not convert offered RPS into achieved throughput.

## Exceptional targeted recovery

Targeting is permitted only when live refresh proves the CCE cluster/node pool were deleted outside Terraform and a normal plan would mix unrelated cloud drift. The recovery preview must be exactly `2 to add, 0 to change, 0 to destroy`. After apply:

1. Run refresh-only reconciliation and verify the CCE EIP is bound.
2. Download a fresh Huawei-issued kubeconfig and client key.
3. Verify both nodes are Ready.
4. Deploy with `IRESTRICT_TARGET_CLOUD=huawei`.
5. Run T00-T07 and evidence collection.
6. Review a full un-targeted plan; do not blindly apply unrelated Azure drift.

## STRIDE evidence

T00-T07 are control tests, not a complete threat model. Use [the STRIDE test plan](stride-test-plan.md) to state which categories are validated, partially validated, target design, or not tested.

After the ordinary replay passes, run the dedicated suite inside the approved lab/load window:

```bash
export KUBECONFIG="$HOME/.kube/irestrict-huawei/kubeconfig.yaml"
STRIDE_MIVA_CONFIRMED=true STRIDE_LOAD_CONFIRMED=true ./scripts/replay-stride.sh huawei
```

Accept the run only when the baseline matrix, supplementary harnesses, live STRIDE matrix and evidence checksums all pass. Preserve the prior evidence directories; the STRIDE run uses a new run ID.
