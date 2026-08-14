# iRestrict Self-Run Login and Test Guide

This guide replays the laboratory evaluation without exposing credentials or tying the repository to one operator account. Obtain the approved subscription, resource-group and enterprise-project values from the private handoff or your cloud administrator.

## Current state

The dedicated Azure and Huawei laboratory was rebuilt on 11 August 2026 and remained running after evidence collection. Confirm current state before following the running-lab path; cloud state may have changed after this snapshot.

## 1. Prerequisites

- Terraform 1.15.x compatible CLI
- Azure CLI and access to the approved lab subscription/resource group
- kubectl compatible with the AKS and CCE control-plane versions
- HCP Terraform access to `oche-miva / miva-zero-trust-api-lab`
- Huawei IAM credentials scoped to the approved lab enterprise project
- Bash, Python 3 and standard Unix utilities

From the repository root:

```bash
terraform version
az version
kubectl version --client
./scripts/labctl.sh validate
./scripts/labctl.sh status
```

## 2. Set your approved targets

```bash
export IRESTRICT_AZURE_SUBSCRIPTION='<approved-subscription-id-or-name>'
export IRESTRICT_AZURE_RESOURCE_GROUP='Jane_Lab'
export IRESTRICT_AKS_CLUSTER='aks-irestrict-v3-lab'
export IRESTRICT_HUAWEI_KUBECONFIG="$HOME/.kube/irestrict-huawei/kubeconfig.yaml"
```

Historical `irestrict-v3` resource names are literal Terraform-state identifiers. The artefact name in the report is iRestrict.

## 3. Connect to Azure AKS

```bash
az login
az account set --subscription "$IRESTRICT_AZURE_SUBSCRIPTION"
az account show --query '{subscription:id,name:name,tenant:tenantId}' -o table
az group show -n "$IRESTRICT_AZURE_RESOURCE_GROUP" --query '{name:name,location:location}' -o table
az aks get-credentials \
  --resource-group "$IRESTRICT_AZURE_RESOURCE_GROUP" \
  --name "$IRESTRICT_AKS_CLUSTER" \
  --context irestrict-azure \
  --overwrite-existing
kubectl config use-context irestrict-azure
kubectl get nodes -o wide
kubectl get pods -A
```

Stop if the subscription, resource group, cluster or context differs from the approved dedicated lab.

## 4. Connect to Huawei CCE

Do not obtain operational credentials from Terraform state. After a cluster replacement, provider state can retain the deleted control plane's certificate and private key. In Huawei Console select AF-Johannesburg, open `cce-irestrict-v3-lab`, choose public/external access, and download the current YAML plus `client.key` using the shortest practical validity period.

```bash
mkdir -p "$HOME/.kube/irestrict-huawei"
chmod 700 "$HOME/.kube/irestrict-huawei"
install -m 600 "$HOME/Downloads/cce-irestrict-v3-lab-kubeconfig.yaml" "$IRESTRICT_HUAWEI_KUBECONFIG"
install -m 600 "$HOME/Downloads/client.key" "$HOME/.kube/irestrict-huawei/client.key"

KUBECONFIG="$IRESTRICT_HUAWEI_KUBECONFIG" kubectl config current-context
KUBECONFIG="$IRESTRICT_HUAWEI_KUBECONFIG" kubectl get nodes -o wide
KUBECONFIG="$IRESTRICT_HUAWEI_KUBECONFIG" kubectl get pods -A
```

## 5. Deploy or refresh workloads

Run once per selected context. The script requires an explicit confirmation variable and applies only repository manifests.

Azure:

```bash
unset KUBECONFIG
kubectl config use-context irestrict-azure
kubectl config current-context
IRESTRICT_TARGET_CLOUD=azure DEPLOY_MIVA_CONFIRMED=true ./scripts/deploy-k8s-manifests.sh
kubectl rollout status -n irestrict-apps deployment/sample-financial-api --timeout=180s
kubectl get pods -A
```

Huawei:

```bash
export KUBECONFIG="$IRESTRICT_HUAWEI_KUBECONFIG"
kubectl config current-context
IRESTRICT_TARGET_CLOUD=huawei DEPLOY_MIVA_CONFIRMED=true ./scripts/deploy-k8s-manifests.sh
kubectl rollout status -n irestrict-apps deployment/sample-financial-api --timeout=180s
kubectl get pods -A
```

## 6. Run T00-T07 and collect evidence

```bash
RUN_ID="manual-$(date +%F-%H%M%S)"
./scripts/run-validation-tests.sh "$RUN_ID"
./scripts/collect-evidence.sh "$RUN_ID"
```

Expected result: T00-T07 show `Pass`. The tests demonstrate policy-path behaviour with controlled DPoP-, mTLS- and SPIFFE-style signals; they do not establish production cryptographic enforcement.

For the final prototype STRIDE confirmation, run the dedicated replay during the approved bounded-load window:

```bash
STRIDE_MIVA_CONFIRMED=true STRIDE_LOAD_CONFIRMED=true ./scripts/replay-stride.sh huawei
```

Accept it only when the baseline, DPoP, requirements, live STRIDE cases, evidence secret scan and checksums pass. The 40-request burst is a bounded recovery check, not a production-capacity or destructive denial-of-service test. Production gateway proof enforcement and immutable audit retention remain target-design claims.

## 7. Run matched performance trials

Use alternating order to reduce warm-up/order bias:

```bash
K6_VUS=50 K6_DURATION=15s K6_BASELINE_START=0s K6_SECURED_START=20s \
  ./scripts/run-k6-benchmark.sh "${RUN_ID}-baseline-first"

K6_VUS=50 K6_DURATION=15s K6_BASELINE_START=20s K6_SECURED_START=0s \
  ./scripts/run-k6-benchmark.sh "${RUN_ID}-secured-first"
```

The baseline calls the same endpoint and response shape but bypasses the OPA HTTP decision. Report the measured P50/P95/P99, failure rate and request count from the raw log. Do not describe the difference as full DPoP/mTLS/SPIFFE overhead.

## 8. Run the fixed-rate cross-cloud standard

```bash
K6_RATE=300 K6_DURATION=60s \
  ./scripts/run-k6-standard.sh "${RUN_ID}-300rps-60s"
```

Accept the run only when all scheduled iterations complete, HTTP failures remain below 1%, dropped iterations are zero, workload restart counts do not increase, and the post-test health check passes. Report P50, P95 and P99 from the retained raw log. Run the identical command and workload configuration in each cloud.

## 9. Supplementary local harnesses

```bash
./scripts/bootstrap-python.sh
.venv/bin/python scripts/dpop_crypto_validation.py
.venv/bin/python scripts/local_requirement_validation.py
```

These are separate from the cloud policy-path test and must be reported separately.

## 10. Evidence to preserve

- cloud and Kubernetes context, with credentials removed
- Terraform and provider versions
- cluster version, node size/count and pod inventory
- exact script command and order
- generated k6 script and Kubernetes Job manifest
- raw k6 log and derived summary
- T00-T07 raw JSONL and Markdown result
- UTC timestamp and any retries, image-pull failures or deviations

## 11. Teardown

```bash
unset KUBECONFIG
./scripts/labctl.sh destroy-plan
```

Review the destroy plan and approve it in HCP Terraform only after explicit teardown approval. Remove local kubeconfigs after the lab is destroyed.

## 12. Exceptional Huawei recovery

Use targeting only to recover resources confirmed deleted out of band. Preview first and approve only `2 to add, 0 to change, 0 to destroy`:

```bash
terraform -chdir=terraform/envs/lab plan \
  -target='module.huawei_platform[0].huaweicloud_cce_cluster.this[0]' \
  -target='module.huawei_platform[0].huaweicloud_cce_node_pool.this[0]'
```

Apply the same two targets only after explicit approval. Then run a refresh-only reconciliation, verify the EIP is `BOUND`, obtain a newly issued Huawei kubeconfig, and run a full un-targeted plan for review. Never paste drift output containing `kube_config_raw`; historical state may reveal private-key material.

Registry pulls from Docker Hub or GHCR may take several minutes. Inspect pod events before changing an image tag; transient `ImagePullBackOff` during the 14 August recovery resolved automatically.
