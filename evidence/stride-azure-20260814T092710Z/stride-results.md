# Live STRIDE Validation Results

Passed: 15/15

| ID | Category | Scenario | Expected | Actual | Result |
|---|---|---|---:|---:|---|
| S01 | Spoofing | Missing proof rejected | 403 | 403 | Pass |
| T01 | Tampering | Proof HTTP method mismatch rejected | 403 | 403 | Pass |
| T02 | Tampering | Proof URI mismatch rejected | 403 | 403 | Pass |
| T03 | Tampering | Post-signing body modification rejected | 403 | 403 | Pass |
| I01 | Information Disclosure | Authorized response remains redacted | 200 | 200 | Pass |
| E01 | Elevation of Privilege | Ordinary account scope denied on admin route | 403 | 403 | Pass |
| E02 | Elevation of Privilege | Unknown workload denied on admin route | 403 | 403 | Pass |
| R-stride-s01 | Repudiation | correlated audit record present | 1 | 1 | Pass |
| R-stride-t01 | Repudiation | correlated audit record present | 1 | 1 | Pass |
| R-stride-t02 | Repudiation | correlated audit record present | 1 | 1 | Pass |
| R-stride-t03 | Repudiation | correlated audit record present | 1 | 1 | Pass |
| R-stride-i01 | Repudiation | correlated audit record present | 1 | 1 | Pass |
| R-stride-e01 | Repudiation | correlated audit record present | 1 | 1 | Pass |
| R-stride-e02 | Repudiation | correlated audit record present | 1 | 1 | Pass |
| D01 | Denial of Service | bounded 40-request burst and recovery | 200 | 200 | Pass |
