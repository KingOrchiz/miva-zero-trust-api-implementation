# iRestrict STRIDE Test Plan

## Purpose

STRIDE is a threat-modelling method, not a single test command. A defence claim is complete only when each identified threat has a control, a repeatable test, an expected result, and preserved evidence. The existing T00-T07 matrix is one part of this assessment.

## Current coverage

| STRIDE category | Existing evidence | What it demonstrates | Remaining explicit test |
|---|---|---|---|
| Spoofing | T02-T04; DPoP harness; S01 | Missing proof, invalid mTLS-style context and wrong workload identity are denied | Production gateway proof verification remains target design |
| Tampering | DPoP harness; live T01-T03 | Method, URI and request-body changes after proof creation are rejected | Production gateway body binding remains target design |
| Repudiation | Live R-* cases and API audit logs | Every STRIDE request is correlated to actor/workload, route, decision, reason and timestamp | Immutable cloud retention remains target design unless separately evidenced |
| Information disclosure | I01 and evidence sanitizer | Expected responses remain redacted and do not contain common secret markers | External DLP tooling is optional supplementary assurance |
| Denial of service | T00; gated D01; matched k6/capacity runs | Health, a bounded 40-request burst and recovery are measured | Destructive exhaustion testing is out of scope |
| Elevation of privilege | T05-T07; live E01-E02 | Wrong scope, high risk, unknown workload and ordinary-user access to an admin route are denied | Production administrative IAM integration remains target design |

## Acceptance rule

A STRIDE category is `Validated` only when its test passes in the named environment and the evidence bundle contains context, timestamp, exact command, expected/actual result, relevant logs and checksums. Otherwise label it `Partially validated`, `Target design`, or `Not tested`.

## Defence-day sequence

1. State the threat and trust boundary.
2. Run T00-T07 and retain raw JSONL plus Markdown results.
3. Run the DPoP 8/8 and local-requirement 6/6 harnesses in the pinned virtual environment.
4. Run the live STRIDE suite with `STRIDE_MIVA_CONFIRMED=true`; add `STRIDE_LOAD_CONFIRMED=true` only inside the approved load window.
5. Preserve `stride-results.jsonl`, `stride-results.md`, correlated API audit logs and checksums.
6. Map results to this table without claiming that controlled headers equal production cryptographic enforcement or that ordinary logs are immutable storage.

## Complete replay command

```bash
export KUBECONFIG="$HOME/.kube/irestrict-huawei/kubeconfig.yaml"
STRIDE_MIVA_CONFIRMED=true STRIDE_LOAD_CONFIRMED=true ./scripts/replay-stride.sh huawei
```

The bounded load case sends 40 concurrent health requests and then requires the deployment to remain available and `/healthz` to return HTTP 200. It is a safe recovery check, not an attempt to exhaust the cluster or claim a production capacity limit.

## Classification rule

For this prototype, a category may be marked `Validated in the prototype lab` only when every implemented case passes and its evidence checksum validates. Controls that depend on a production-grade gateway, immutable retention service, enterprise IAM or destructive capacity testing remain explicitly `Target design` or `Out of scope`; they are not silently converted into implementation claims.
