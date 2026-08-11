#!/usr/bin/env python3
"""Supplementary RFC 9449 DPoP proof-of-possession validation for iRestrict V3.

This is a local, cloud-free evidence generator. It verifies the cryptographic path that
the Kubernetes laboratory represented with controlled validation headers.
"""
import base64
import hashlib
import json
import time
import uuid
from pathlib import Path

import jwt
from cryptography.hazmat.primitives.asymmetric import ec

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "evidence" / "irestrict-v3-2026-07-26-dpop-crypto"
OUT.mkdir(parents=True, exist_ok=True)

ACCESS_TOKEN_SECRET = "local-lab-only-secret-for-dpop-evidence"
HTM = "GET"
HTU = "https://api.irestrict.local/v1/accounts"


def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def int_b64url(value: int) -> str:
    length = max(1, (value.bit_length() + 7) // 8)
    return b64url(value.to_bytes(length, "big"))


def jwk_from_public_key(public_key) -> dict:
    numbers = public_key.public_numbers()
    return {"kty": "EC", "crv": "P-256", "x": int_b64url(numbers.x), "y": int_b64url(numbers.y)}


def jwk_thumbprint(jwk: dict) -> str:
    canonical = json.dumps({"crv": jwk["crv"], "kty": jwk["kty"], "x": jwk["x"], "y": jwk["y"]}, separators=(",", ":"), sort_keys=True).encode()
    return b64url(hashlib.sha256(canonical).digest())


def make_keypair():
    private_key = ec.generate_private_key(ec.SECP256R1())
    jwk = jwk_from_public_key(private_key.public_key())
    return private_key, jwk, jwk_thumbprint(jwk)


def make_access_token(jkt: str) -> str:
    now = int(time.time())
    claims = {
        "iss": "https://keycloak.irestrict.local/realms/miva",
        "sub": "synthetic-client-001",
        "aud": "irestrict-financial-api",
        "scope": "accounts.read payments.write",
        "iat": now,
        "exp": now + 300,
        "cnf": {"jkt": jkt},
    }
    return jwt.encode(claims, ACCESS_TOKEN_SECRET, algorithm="HS256")


def access_token_claims(access_token: str) -> dict:
    return jwt.decode(access_token, ACCESS_TOKEN_SECRET, algorithms=["HS256"], audience="irestrict-financial-api")


def make_dpop(private_key, jwk, access_token, htm=HTM, htu=HTU, iat=None, jti=None) -> str:
    now = int(time.time()) if iat is None else iat
    claims = {
        "htu": htu,
        "htm": htm,
        "iat": now,
        "jti": jti or str(uuid.uuid4()),
        "ath": b64url(hashlib.sha256(access_token.encode()).digest()),
    }
    return jwt.encode(claims, private_key, algorithm="ES256", headers={"typ": "dpop+jwt", "alg": "ES256", "jwk": jwk})


class DPoPVerifier:
    def __init__(self):
        self.seen_jti = set()

    def verify(self, access_token: str, proof: str | None, method: str, uri: str) -> tuple[bool, str]:
        if not proof:
            return False, "missing_dpop_proof"
        try:
            token_claims = access_token_claims(access_token)
            header = jwt.get_unverified_header(proof)
            jwk = header.get("jwk")
            if header.get("typ") != "dpop+jwt" or not jwk:
                return False, "invalid_dpop_header"
            public_key = jwt.algorithms.ECAlgorithm.from_jwk(json.dumps(jwk))
            claims = jwt.decode(proof, public_key, algorithms=["ES256"], options={"verify_aud": False})
        except Exception as exc:
            return False, f"invalid_signature_or_token:{type(exc).__name__}"

        if jwk_thumbprint(jwk) != token_claims.get("cnf", {}).get("jkt"):
            return False, "jwk_thumbprint_mismatch"
        if claims.get("htm") != method:
            return False, "http_method_mismatch"
        if claims.get("htu") != uri:
            return False, "http_uri_mismatch"
        if claims.get("ath") != b64url(hashlib.sha256(access_token.encode()).digest()):
            return False, "access_token_hash_mismatch"
        if abs(int(time.time()) - int(claims.get("iat", 0))) > 120:
            return False, "proof_expired_or_not_yet_valid"
        jti = claims.get("jti")
        if not jti:
            return False, "missing_jti"
        if jti in self.seen_jti:
            return False, "replayed_jti"
        self.seen_jti.add(jti)
        return True, "valid_dpop_proof"


def run():
    client_key, client_jwk, client_jkt = make_keypair()
    attacker_key, attacker_jwk, _ = make_keypair()
    access_token = make_access_token(client_jkt)
    verifier = DPoPVerifier()

    replay_jti = str(uuid.uuid4())
    replay_proof = make_dpop(client_key, client_jwk, access_token, jti=replay_jti)

    cases = [
        ("DPOP-01", "Valid DPoP proof with matching key, method, URI, ath, and fresh jti", True, lambda: make_dpop(client_key, client_jwk, access_token)),
        ("DPOP-02", "Stolen access token without DPoP proof", False, lambda: None),
        ("DPOP-03", "Stolen token with attacker key, cnf.jkt mismatch", False, lambda: make_dpop(attacker_key, attacker_jwk, access_token)),
        ("DPOP-04a", "First use of jti accepted", True, lambda: replay_proof),
        ("DPOP-04b", "Replayed jti rejected", False, lambda: replay_proof),
        ("DPOP-05", "HTTP method mismatch rejected", False, lambda: make_dpop(client_key, client_jwk, access_token, htm="POST")),
        ("DPOP-06", "HTTP URI mismatch rejected", False, lambda: make_dpop(client_key, client_jwk, access_token, htu="https://api.irestrict.local/v1/payments")),
        ("DPOP-07", "Expired proof iat rejected", False, lambda: make_dpop(client_key, client_jwk, access_token, iat=int(time.time()) - 600)),
    ]

    results = []
    for cid, scenario, expected, proof_fn in cases:
        proof = proof_fn()
        actual, reason = verifier.verify(access_token, proof, HTM, HTU)
        results.append({
            "id": cid,
            "scenario": scenario,
            "expected_allow": expected,
            "actual_allow": actual,
            "result": "Pass" if actual == expected else "Fail",
            "decision_reason": reason,
        })

    (OUT / "dpop-crypto-results.json").write_text(json.dumps({"generated_at_epoch": int(time.time()), "cases": results}, indent=2))

    passed = sum(1 for r in results if r["result"] == "Pass")
    lines = [
        "# Supplementary DPoP Cryptographic Validation Evidence",
        "",
        "This evidence validates the RFC 9449 proof-of-possession path locally, without redeploying cloud infrastructure. It complements the Azure/Huawei laboratory evidence, where DPoP, mTLS, and SPIFFE signals were represented by controlled validation headers.",
        "",
        f"Result: {passed}/{len(results)} cases passed.",
        "",
        "| Test ID | Scenario | Expected | Actual | Status | Decision reason |",
        "|---|---|---:|---:|---|---|",
    ]
    for r in results:
        lines.append(f"| {r['id']} | {r['scenario']} | {'Allow' if r['expected_allow'] else 'Deny'} | {'Allow' if r['actual_allow'] else 'Deny'} | {r['result']} | `{r['decision_reason']}` |")
    lines += [
        "",
        "Validation coverage: DPoP proof JWT signature verification using ES256, public-key thumbprint binding through `cnf.jkt`, HTTP method binding (`htm`), HTTP URI binding (`htu`), issued-at freshness (`iat`), unique request identifier replay prevention (`jti`), and access-token hash binding (`ath`).",
        "",
        "Interpretation: a stolen access token alone is insufficient; an attacker must also possess the matching private key and produce a fresh, request-bound proof. Wrong-key, replay, method-mismatch, URI-mismatch, and expired-proof cases are rejected.",
    ]
    (OUT / "dpop-crypto-results.md").write_text("\n".join(lines) + "\n")
    print(json.dumps({"out": str(OUT), "passed": passed, "total": len(results), "all_passed": passed == len(results)}, indent=2))


if __name__ == "__main__":
    run()
