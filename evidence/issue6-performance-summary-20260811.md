# Issue 6 Performance and Capacity Evidence

Collected on 11 August 2026 after a clean Terraform redeployment of the dedicated iRestrict laboratory.

## Test boundary

The matched benchmark used the same `/v1/accounts` endpoint, request context, and response shape for both paths. The lab-only baseline bypassed the OPA HTTP decision. The secured path performed the OPA decision. Both paths used controlled DPoP-, mTLS-, and SPIFFE-style inputs. The test therefore isolates the application-plus-policy path; it does not measure production DPoP verification, certificate-bound mTLS, SPIFFE federation, internet latency, or a banking workload.

Each tagged comparison used 50 virtual users. Two trials were run per cloud with the path order reversed to reduce systematic warm-up bias. All four comparison trials recorded zero HTTP failures.

## Matched P95 results

| Cloud | Trial order | Baseline P95 | Secured P95 | P95 path increase |
|---|---|---:|---:|---:|
| Azure AKS | baseline first | 12.26 ms | 121.74 ms | 109.48 ms |
| Azure AKS | secured first | 12.15 ms | 133.57 ms | 121.42 ms |
| Huawei CCE | baseline first | 5.29 ms | 32.82 ms | 27.53 ms |
| Huawei CCE | secured first | 4.73 ms | 28.38 ms | 23.65 ms |

The 30 ms P95 design target was not met on the Azure configuration. It was met only for the bounded Huawei policy-path comparison. This is not evidence that the complete target architecture meets a 30 ms overhead target.

## Capacity ladder

The secured policy path was offered 500, 1,000, 2,000, 5,000, and 10,000 requests per second in ten-second stages. Higher stages saturated the lean clusters and the colocated k6 generator, causing dropped or interrupted iterations and tail-latency growth.

- At the 500 RPS stage, Huawei completed 5,002 requests with zero HTTP failures and a 23 ms P95 duration.
- At the 500 RPS stage, Azure completed 3,203 requests with zero HTTP failures but a 3.40 s P95 duration; it did not sustain the offered rate.
- At the 10,000 RPS stage, Azure completed 3,376 tagged requests; Huawei completed 8,647. Neither environment sustained the target.
- Across the full ladder, Azure recorded 166,250 dropped iterations and Huawei 143,785. These aggregate values include overlap caused by requests continuing beyond their scheduled stage and must not be presented as stage-specific drop counts.

The 10,000 TPS requirement was not achieved in this lean laboratory configuration.

## Evidence files

- `evidence/azure-issue6-tagged-01/`
- `evidence/azure-issue6-tagged-02/`
- `evidence/huawei-issue6-tagged-01/`
- `evidence/huawei-issue6-tagged-02/`
- `evidence/azure-issue6-capacity-20260811/`
- `evidence/huawei-issue6-capacity-20260811/`
- `scripts/run-k6-benchmark.sh`
- `scripts/run-k6-capacity.sh`

## Reproduction

Select the intended cluster context, redeploy `k8s/apps/sample-api.yaml`, wait for rollout completion, and run:

```bash
K6_VUS=50 K6_DURATION=15s K6_BASELINE_START=0s K6_SECURED_START=20s \
  ./scripts/run-k6-benchmark.sh <cloud>-tagged-01

K6_VUS=50 K6_DURATION=15s K6_BASELINE_START=20s K6_SECURED_START=0s \
  ./scripts/run-k6-benchmark.sh <cloud>-tagged-02

./scripts/run-k6-capacity.sh <cloud>-capacity
```

Record cluster versions, node sizes, node counts, pod counts, raw logs, job manifests, and any startup or image-pull failures alongside each run.
