# iRestrict STRIDE Test Plan

## Purpose

STRIDE is a threat-modelling method, not a single test command. A defence claim is complete only when each identified threat has a control, a repeatable test, an expected result, and preserved evidence. The existing T00-T07 matrix is one part of this assessment.

## Current coverage

| STRIDE category | Existing evidence | What it demonstrates | Remaining explicit test |
|---|---|---|---|
| Spoofing | T02-T04; local DPoP harness | Missing proof, invalid mTLS-style context and wrong workload identity are denied | Cryptographically invalid/expired proof against a production-grade gateway |
| Tampering | DPoP signature harness | Modified signed claims fail local verification | Modify request body/path after proof creation and verify live gateway rejection |
| Repudiation | OTel/API logs | Decisions can be correlated to a run | Verify actor, decision, timestamp and immutable retention controls |
| Information disclosure | Redacted API response; evidence sanitizer | Account balance and credentials are not emitted in expected output | Automated secret scan and unauthorized-field assertions over all evidence |
| Denial of service | T00; matched k6/capacity runs | Service health and bounded saturation behaviour | Rate-limit, resource-exhaustion and recovery tests with agreed safety ceilings |
| Elevation of privilege | T05-T07 | Wrong scope/high risk denied; valid payment context allowed | Role-boundary and administrative-route negative tests |

## Acceptance rule

A STRIDE category is `Validated` only when its test passes in the named environment and the evidence bundle contains context, timestamp, exact command, expected/actual result, relevant logs and checksums. Otherwise label it `Partially validated`, `Target design`, or `Not tested`.

## Defence-day sequence

1. State the threat and trust boundary.
2. Run T00-T07 and retain raw JSONL plus Markdown results.
3. Run the DPoP 8/8 and local-requirement 6/6 harnesses in the pinned virtual environment.
4. Run only the approved bounded performance/availability scenario.
5. Map results to this table without claiming that controlled headers equal production cryptographic enforcement.
