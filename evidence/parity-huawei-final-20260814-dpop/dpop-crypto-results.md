# Supplementary DPoP Cryptographic Validation Evidence

This evidence validates the RFC 9449 proof-of-possession path locally, without redeploying cloud infrastructure. It complements the Azure/Huawei laboratory evidence, where DPoP, mTLS, and SPIFFE signals were represented by controlled validation headers.

Result: 8/8 cases passed.

| Test ID | Scenario | Expected | Actual | Status | Decision reason |
|---|---|---:|---:|---|---|
| DPOP-01 | Valid DPoP proof with matching key, method, URI, ath, and fresh jti | Allow | Allow | Pass | `valid_dpop_proof` |
| DPOP-02 | Stolen access token without DPoP proof | Deny | Deny | Pass | `missing_dpop_proof` |
| DPOP-03 | Stolen token with attacker key, cnf.jkt mismatch | Deny | Deny | Pass | `jwk_thumbprint_mismatch` |
| DPOP-04a | First use of jti accepted | Allow | Allow | Pass | `valid_dpop_proof` |
| DPOP-04b | Replayed jti rejected | Deny | Deny | Pass | `replayed_jti` |
| DPOP-05 | HTTP method mismatch rejected | Deny | Deny | Pass | `http_method_mismatch` |
| DPOP-06 | HTTP URI mismatch rejected | Deny | Deny | Pass | `http_uri_mismatch` |
| DPOP-07 | Expired proof iat rejected | Deny | Deny | Pass | `proof_expired_or_not_yet_valid` |

Validation coverage: DPoP proof JWT signature verification using ES256, public-key thumbprint binding through `cnf.jkt`, HTTP method binding (`htm`), HTTP URI binding (`htu`), issued-at freshness (`iat`), unique request identifier replay prevention (`jti`), and access-token hash binding (`ath`).

Interpretation: a stolen access token alone is insufficient; an attacker must also possess the matching private key and produce a fresh, request-bound proof. Wrong-key, replay, method-mismatch, URI-mismatch, and expired-proof cases are rejected.
