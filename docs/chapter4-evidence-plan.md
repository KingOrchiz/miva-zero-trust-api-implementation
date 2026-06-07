# Chapter 4 Evidence Plan

This file defines the evidence to capture during implementation and testing.

## Required evidence

1. Infrastructure evidence
- Terraform plan output
- Terraform apply output, when approved
- Resource inventory after deployment
- Cluster access verification

2. Identity evidence
- Keycloak realm and client configuration screenshots or exported JSON
- DPoP client configuration
- OIDC token claims example with sensitive values redacted

3. Workload identity evidence
- SPIRE server and agent status
- SPIFFE ID assignment for workloads
- mTLS status between services

4. Policy evidence
- OPA policies deployed
- Allowed request decision log
- Denied request decision log

5. Security test evidence
- Valid DPoP request succeeds
- Stolen token without DPoP fails
- Invalid DPoP signature fails
- Wrong mTLS identity fails
- Wrong SPIFFE identity fails
- Unauthorized route/method fails

6. Performance evidence
- Baseline request latency
- Secured request latency
- Overhead percentage

7. Auditability evidence
- OpenTelemetry trace ID per test
- API request logs
- OPA decision logs
- Gateway/authentication logs

## Evidence storage

Store evidence under:

`evidence/YYYY-MM-DD-test-run/`

Suggested files:

- `terraform-plan.txt`
- `terraform-apply.txt`
- `cluster-inventory.txt`
- `keycloak-config-redacted.json`
- `spire-status.txt`
- `opa-decision-logs.jsonl`
- `otel-trace-summary.txt`
- `security-test-results.md`
- `latency-results.csv`
- `chapter4-evidence-summary.md`
