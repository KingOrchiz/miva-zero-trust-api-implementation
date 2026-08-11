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
export IRESTRICT_HUAWEI_KUBECONFIG="$HOME/.kube/irestrict-huawei.yaml"
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

The `huawei_kube_config_raw` Terraform output is sensitive. Write it to a protected file; never commit or paste it into evidence.

```bash
mkdir -p "$(dirname "$IRESTRICT_HUAWEI_KUBECONFIG")"
cd terraform/envs/lab
terraform output -raw huawei_kube_config_raw > "$IRESTRICT_HUAWEI_KUBECONFIG"
chmod 600 "$IRESTRICT_HUAWEI_KUBECONFIG"
cd ../../..

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
DEPLOY_MIVA_CONFIRMED=true ./scripts/deploy-k8s-manifests.sh
kubectl rollout status -n irestrict-apps deployment/sample-financial-api --timeout=180s
kubectl get pods -A
```

Huawei:

```bash
export KUBECONFIG="$IRESTRICT_HUAWEI_KUBECONFIG"
kubectl config current-context
DEPLOY_MIVA_CONFIRMED=true ./scripts/deploy-k8s-manifests.sh
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

## 7. Run matched performance trials

Use alternating order to reduce warm-up/order bias:

```bash
K6_VUS=50 K6_DURATION=15s K6_BASELINE_START=0s K6_SECURED_START=20s \
  ./scripts/run-k6-benchmark.sh "${RUN_ID}-baseline-first"

K6_VUS=50 K6_DURATION=15s K6_BASELINE_START=20s K6_SECURED_START=0s \
  ./scripts/run-k6-benchmark.sh "${RUN_ID}-secured-first"
```

The baseline calls the same endpoint and response shape but bypasses the OPA HTTP decision. Report the measured P50/P95/P99, failure rate and request count from the raw log. Do not describe the difference as full DPoP/mTLS/SPIFFE overhead.

## 8. Run the capacity ladder

```bash
./scripts/run-k6-capacity.sh "${RUN_ID}-capacity"
```

The job offers 500, 1,000, 2,000, 5,000 and 10,000 RPS. A configured offered rate is not achieved throughput. Use completed requests, dropped iterations, latency and failures to determine the sustainable boundary.

## 9. Supplementary local harnesses

```bash
python3 scripts/dpop_crypto_validation.py
python3 scripts/local_requirement_validation.py
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
