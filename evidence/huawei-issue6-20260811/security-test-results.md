# iRestrict Version 3 Security Validation Results

Collected: 2026-08-11T11:50:20.679853+01:00

| Test ID | Scenario | Expected Result | Actual Result | Status | Evidence |
|---|---|---:|---:|---|---|
| T00 | Health endpoint | HTTP 200 | HTTP 200 | Pass | {   "status": "ok",   "service": "sample-financial-api" } |
| T01 | Valid OPA decision with scope, DPoP, mTLS, and SPIFFE-style workload identity | HTTP 200 | HTTP 200 | Pass | {   "decision": "allow",   "policy": "OPA",   "workload_identity": "spiffe://miva.local/ns/irestrict-apps/sa/sample-financial-api",   "accounts": [     {       "id": "demo-001",    |
| T02 | Stolen token simulation without DPoP proof | HTTP 403 | HTTP 403 | Pass | {   "decision": "deny",   "deny_reason": [     "invalid_dpop"   ],   "input": {     "method": "GET",     "path": [       "v1",       "accounts"     ],     "claims": {       "scope" |
| T03 | Invalid mTLS context | HTTP 403 | HTTP 403 | Pass | {   "decision": "deny",   "deny_reason": [     "mtls_not_verified"   ],   "input": {     "method": "GET",     "path": [       "v1",       "accounts"     ],     "claims": {       "s |
| T04 | Wrong workload identity | HTTP 403 | HTTP 403 | Pass | {   "decision": "deny",   "deny_reason": [     "invalid_workload_identity"   ],   "input": {     "method": "GET",     "path": [       "v1",       "accounts"     ],     "claims": {  |
| T05 | Unauthorized scope for account read | HTTP 403 | HTTP 403 | Pass | {   "decision": "deny",   "deny_reason": [],   "input": {     "method": "GET",     "path": [       "v1",       "accounts"     ],     "claims": {       "scope": [         "payments. |
| T06 | High-risk payment context denied | HTTP 403 | HTTP 403 | Pass | {   "decision": "deny",   "deny_reason": [],   "input": {     "method": "POST",     "path": [       "v1",       "payments"     ],     "claims": {       "scope": [         "payments |
| T07 | Valid payment context allowed | HTTP 200 | HTTP 200 | Pass | {   "decision": "allow",   "policy": "OPA",   "workload_identity": "spiffe://miva.local/ns/irestrict-apps/sa/sample-financial-api",   "payment": "accepted_for_demo" } |

## Latency observation

Mean observed command round-trip latency: 103.88 ms. Minimum: 95 ms. Maximum: 112 ms.

## Interpretation

The tests show policy-based allow and deny behavior for identity, DPoP-style proof, mTLS-style verification, SPIFFE-style workload identity, route authorization, and contextual risk. The proof signals are represented as controlled validation headers in the prototype API so the dissertation can demonstrate the authorization logic without relying on production certificates or live banking data.
