# iRestrict Credential Lifecycle

## Rules

- Keep durable cloud secrets only in sensitive HCP Terraform variables or an approved secret store.
- Keep kubeconfigs and client keys outside the repository with directory mode `700` and file mode `600`.
- Never export CCE operational credentials from Terraform state, paste them into chat, or include them in evidence.
- Record credential name/purpose, owner, scope, issue date, expiry and rotation date; never record its value.

## Huawei CCE

Issue a new public/external-access YAML and `client.key` from the current CCE cluster using the shortest practical validity period. Reissue after any cluster replacement. Store under `~/.kube/irestrict-huawei/`, verify the expected external context and two Ready nodes, and delete/revoke the credential after teardown or defence completion.

## Azure AKS

Refresh credentials through `az aks get-credentials` only after verifying the approved subscription, resource group and cluster. Use the dedicated `irestrict-azure` context.

## Other lab credentials

Rotate or discard the Huawei node password, Keycloak development administrator secret and temporary operator tokens after the evidence window. Do not preserve short-lived secrets as a reproducibility mechanism; preserve the issuance procedure and non-secret configuration instead.

## Exposure response

If a key appears in terminal output, chat, screenshots or evidence: stop forwarding it, remove/redact recoverable copies, revoke or supersede the credential, issue a new one, and record a sanitized incident note. A deleted cluster may make an old key unusable, but it must still be treated as exposed.
