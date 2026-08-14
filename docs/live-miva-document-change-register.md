# Proposed Live MIVA Document Change Register

Status: **read-only proposal; not applied to the submitted/live document**

The submitted version remains authoritative pending a separate paragraph-by-paragraph review with Oche. No live-document edit is authorized by this repository hardening work.

## Proposed later corrections

1. Add a dated operational-recovery addendum for the 13 August out-of-band Huawei CCE removal and 14 August recovery.
2. Preserve the historical 11 August T00-T07 8/8 claims and add the distinct 14 August post-recovery replay: T00-T07 8/8, DPoP 8/8, requirements 6/6 and 33/33 checksummed evidence artifacts under `evidence/defence-huawei-20260814T074705Z`.
3. Qualify the Huawei control-plane diagram/text: the recovered lab used the approved bound external EIP and a newly issued CCE credential.
4. Reconcile Keycloak narrative/version references with the evidenced `26.0.7` manifest.
5. Mark Redis replay cache, Istio mTLS, Prometheus/Grafana, issued SVIDs and immutable audit storage as target design unless direct deployment evidence exists.
6. Add the STRIDE coverage table and final live-suite results only after `replay-stride.sh` passes on Huawei. Categorize prototype-lab validation separately from production gateway cryptography, enterprise IAM and immutable-retention target design.
7. Refresh only screenshots or appendix references that show the deleted cluster identity or obsolete endpoint state.
8. Explain that the recorded 751-865 ms observations are kubectl command round-trip timings, not API service latency and not the earlier k6 P95 measurement.
9. Add the live STRIDE evidence by category: proof spoofing; method/URI/body tampering; correlated decision records for repudiation; redacted-response/secret scanning; bounded availability and recovery; and administrative/workload privilege boundaries.

## Review method

For each proposed change, provide the current paragraph, proposed replacement, factual evidence, impact on existing claims, and Oche's accept/reject decision. Apply nothing until that review is complete.
