#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUN_ID="${1:-$(date +%F-%H%M%S)}"
OUT="$ROOT/evidence/$RUN_ID"
mkdir -p "$OUT"
RESULTS="$OUT/security-test-results.md"

cat > "$RESULTS" <<'EOF'
# MIVA Chapter 4 Security Validation Results

Status: template generated. Execute after Keycloak, DPoP client, mTLS ingress, SPIFFE/SPIRE, OPA, and sample API are deployed.

| Test ID | Scenario | Expected Result | Actual Result | Evidence |
|---|---|---|---|---|
| T01 | Valid OIDC + DPoP + mTLS request | Allow | Pending | Pending |
| T02 | Stolen token without DPoP proof | Deny | Pending | Pending |
| T03 | Invalid DPoP signature | Deny | Pending | Pending |
| T04 | Wrong mTLS client identity | Deny | Pending | Pending |
| T05 | Wrong or missing SPIFFE workload ID | Deny | Pending | Pending |
| T06 | Unauthorized route or method | Deny | Pending | Pending |
| T07 | High-risk policy context | Deny | Pending | Pending |
| T08 | Baseline latency versus secured path | Measured | Pending | Pending |

EOF

echo "Validation template written to $RESULTS"
