# Local Requirement Validation Evidence

This evidence closes report-level validation gaps without redeploying cloud infrastructure. It validates executable logic for requirements that were previously design-only. It should be interpreted as local prototype evidence, not production cloud evidence.

Result: 6/6 cases passed.

| Test ID | Requirement | Expected | Actual | Status |
|---|---|---|---|---|
| FR2-CERT-01 | FR-2 / certificate lifetime and renewal | certificate lifetime <= 3600 seconds and renewal triggered before expiry | lifetime=3600s renewed=True old=SVID-0001 new=SVID-0002 | Pass |
| FR7-AUDIT-01 | FR-7 / NFR-6 tamper-evident auditability | valid chain verifies and modified record is rejected | chain_valid=True tamper_detected=True | Pass |
| FR8-REVOCATION-01 | FR-8 / NFR-7 revocation within 60 seconds | identity denied within 60 seconds of revocation event | before=allow after=deny propagation=5s | Pass |
| FR9-IDENTITY-01 | FR-9 identity propagation | workload and end-user identity available in policy input and auditable context | propagated=True decision_allow=True | Pass |
| FR10-BRIDGE-01 | FR-10 controlled legacy bearer-token bridge | approved legacy route allowed with obligations; protected payment route denied | legacy_allow=True obligations=['rate_limit', 'enhanced_audit', 'migration_deadline'] protected_allow=False | Pass |
| NFR4-AGILITY-01 | NFR-4 cryptographic agility | algorithm identifier and key material can be rotated through configuration boundary | supported_algorithms=['ES256', 'EdDSA-ready', 'PQ-hybrid-placeholder'] active=ES256 kid=iuewtA5avoZw1sUF | Pass |

Coverage added:
- FR-2: certificate lifetime and renewal logic within the one-hour design limit.
- FR-7 / NFR-6: hash-chained audit record verification and tamper detection.
- FR-8 / NFR-7: revocation decision propagation within a 60-second acceptance target in the local enforcement model.
- FR-9: end-user and workload identity propagation into policy/audit context.
- FR-10: controlled legacy bridge mode with compensating obligations and denial on protected modern routes.
- NFR-4: cryptographic agility through an algorithm/key abstraction boundary.
