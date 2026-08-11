# Reproducibility Snapshot — 11 August 2026

Snapshot label: `issue9-reproducibility-20260811`

## Included implementation

- Terraform dedicated-lab Azure and Huawei modules and lock file
- Kubernetes manifests for the laboratory workload
- T00-T07 validation and evidence collection scripts
- RFC 9449 DPoP and local requirement-validation harnesses
- matched baseline-versus-OPA and capacity scripts
- Issue 6 Azure/Huawei evidence, job manifests, scripts, raw logs and summaries
- Issue 9 Azure replay evidence
- public self-run and redeployment runbooks

## Verified checks

- `terraform fmt -check -recursive terraform`
- `terraform -chdir=terraform/envs/lab validate`
- `bash -n scripts/*.sh`
- DPoP supplementary harness: 8/8
- local requirement harness: 6/6
- Azure Issue 9 replay: T00-T07 passed 8/8 after refreshing a stale AKS kubeconfig
- Huawei Issue 6 evidence: T00-T07 passed 8/8; the Issue 9 operator host could not complete a fresh replay because the CCE endpoint route/kubeconfig required renewal

## Evidence boundary

The cloud policy path uses controlled DPoP-, mTLS- and SPIFFE-style inputs. Separate local harnesses provide the RFC 9449 and requirement-specific evidence stated in the report. The capacity test reports achieved completions and saturation; offered RPS is not represented as achieved throughput.

## Snapshot identity

After checkout, resolve the immutable commit with:

```bash
git rev-parse issue9-reproducibility-20260811
```

The live report appendix records the resulting commit hash. The tag and commit are local until an authorised push is performed.
