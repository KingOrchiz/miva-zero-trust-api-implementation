# Architecture Overview

## Control planes

1. Identity plane: Keycloak, Entra ID integration, Huawei IAM integration.
2. Authentication plane: OIDC, DPoP, mTLS, asymmetric proof of possession.
3. Workload trust plane: SPIFFE/SPIRE and service mesh mTLS.
4. Authorization plane: OPA policy-as-code.
5. Observability and audit plane: OpenTelemetry, logs, traces, policy decision records, tamper-evident evidence.

## Request path

1. Client authenticates through Keycloak/OIDC.
2. Client signs each request with DPoP proof.
3. Gateway validates token, proof, claims, and request binding.
4. Service mesh enforces mTLS and workload identity.
5. OPA evaluates route, method, identity, workload, and risk policy.
6. API processes the request only after identity-bound checks pass.
7. Logs and traces are exported for audit evidence.
