# iRestrict Security Validation Results

Collected: 2026-08-14T12:44:41.049975+01:00

| Test ID | Scenario | Expected Result | Actual Result | Status | Evidence |
|---|---|---:|---:|---|---|
| T00 | Health endpoint | HTTP 200 | HTTP 200 | Pass | {   "status": "ok",   "service": "sample-financial-api" } |
| T01 | Valid OPA decision with scope, DPoP, mTLS, and SPIFFE-style workload identity | HTTP 200 | HTTP 200 | Pass | {   "decision": "allow",   "policy": "OPA",   "workload_identity": "spiffe://miva.local/ns/irestrict-apps/sa/sample-financial-api",   "correlation_id": "missing",   "accounts": [   |
| T02 | Stolen token simulation without DPoP proof | HTTP 403 | HTTP 403 | Pass | {   "decision": "deny",   "deny_reason": [     "invalid_dpop"   ],   "correlation_id": "missing" } |
| T03 | Invalid mTLS context | HTTP 403 | HTTP 403 | Pass | {   "decision": "deny",   "deny_reason": [     "mtls_not_verified"   ],   "correlation_id": "missing" } |
| T04 | Wrong workload identity | HTTP 403 | HTTP 403 | Pass | {   "decision": "deny",   "deny_reason": [     "invalid_workload_identity"   ],   "correlation_id": "missing" } |
| T05 | Unauthorized scope for account read | HTTP 403 | HTTP 403 | Pass | {   "decision": "deny",   "deny_reason": [],   "correlation_id": "missing" } |
| T06 | High-risk payment context denied | HTTP 403 | HTTP 403 | Pass | {   "decision": "deny",   "deny_reason": [],   "correlation_id": "missing" } |
| T07 | Valid payment context allowed | HTTP 200 | HTTP 200 | Pass | {   "decision": "allow",   "policy": "OPA",   "workload_identity": "spiffe://miva.local/ns/irestrict-apps/sa/sample-financial-api",   "correlation_id": "missing",   "payment": "acc |

## Latency observation

Mean observed command round-trip latency: 1199.25 ms. Minimum: 1147 ms. Maximum: 1296 ms.

## Interpretation

The tests show policy-based allow and deny behavior for identity, DPoP-style proof, mTLS-style verification, SPIFFE-style workload identity, route authorization, and contextual risk. The proof signals are represented as controlled validation headers in the prototype API so the dissertation can demonstrate the authorization logic without relying on production certificates or live banking data.

## STRIDE interpretation

T01-T05 primarily exercise Spoofing and Elevation-of-Privilege controls; T06 exercises contextual authorization against Elevation of Privilege; T00 is an availability check relevant to Denial of Service. These tests do not, by themselves, fully validate Tampering, Repudiation, Information Disclosure, or load-based Denial of Service. See docs/stride-test-plan.md for the explicit coverage and evidence requirements.
