# GitHub and Terraform Access Checklist for MIVA Implementation

## Recommended repository name

Recommended:

`miva-zero-trust-api-implementation`

Alternative shorter name:

`miva-zt-api-auth`

Repository visibility: private.

## Preferred operating model

Use GitHub as the source repository and Terraform Cloud as the execution/control plane.

Recommended workflow:

1. Jane pushes code to GitHub.
2. Pull requests run validation and Terraform plan.
3. Terraform apply is manual-approved only.
4. Cloud credentials are stored in Terraform Cloud workspace variables, not in GitHub code.
5. No secrets are committed to the repository.

## What Oche should provide for GitHub

Preferred option: add Jane as a collaborator to the private repository.

If using a token instead, create a fine-grained GitHub Personal Access Token with access only to the MIVA repository.

Minimum token permissions:

- Repository contents: read/write
- Pull requests: read/write
- Actions: read/write, only if Jane should update GitHub Actions workflows
- Metadata: read

Avoid granting:

- Organization admin
- Account admin
- Delete repository
- All repositories access, unless there is no alternative

Information Jane needs:

- GitHub username or organization name
- Repository name
- Repository URL, if already created
- Whether Jane should push directly to `main` or use pull requests only

Recommended branch policy:

- `main` protected
- Terraform apply only from approved workflow or Terraform Cloud manual approval
- Jane works from feature branches

## What Oche should provide for Terraform Cloud

Preferred option: create a Terraform Cloud organization/workspace and add Jane as a user with limited workspace access.

Workspace name recommendation:

`miva-zero-trust-api-lab`

Workspace execution mode:

- Terraform Cloud remote execution, recommended if cloud credentials will live in Terraform Cloud
- Local execution, only if Oche wants to run Terraform manually from his laptop

Workspace permissions for Jane:

- Read/write variables
- Queue plans
- Read plan output
- Do not grant broad organization admin unless necessary

Apply model:

- Manual approval required for apply
- Auto-apply disabled

Variables needed later, stored as sensitive variables in Terraform Cloud:

### Azure

- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`

### Huawei Cloud

- `HW_ACCESS_KEY`
- `HW_SECRET_KEY`
- `HW_REGION`
- `HW_ENTERPRISE_PROJECT_ID`, if used

### Lab controls

- `MIVA_ENV=lab`
- `MIVA_OWNER=oche-eluma`
- `MIVA_COST_TAG=miva-research-lab`

## Azure access, to discuss next

Recommended model:

- Dedicated Azure resource group for MIVA lab
- Dedicated service principal scoped only to that resource group
- Manual approval before Terraform apply
- Strict tags and teardown process

Jane should not receive broad subscription owner rights if avoidable.

## Huawei Cloud access, to discuss next

Recommended model:

- Dedicated Huawei Cloud project or enterprise project for MIVA lab
- Dedicated IAM user or access key scoped only to required lab services
- Manual approval before Terraform apply
- Strict tags and teardown process

## What not to send in chat

Do not paste raw secrets into Telegram or WhatsApp.

For credentials, use one of these safer routes:

1. Add Jane directly as a collaborator/user in GitHub and Terraform Cloud.
2. Put secrets directly into Terraform Cloud sensitive workspace variables yourself.
3. If a token must be shared, use a short-lived, fine-grained token with limited repository/workspace scope and revoke it after setup.

## Immediate next steps

1. Create or confirm GitHub repo: `miva-zero-trust-api-implementation`.
2. Add Jane or provide a fine-grained repo token.
3. Create Terraform Cloud workspace: `miva-zero-trust-api-lab`.
4. Keep Terraform apply manual-approved.
5. Confirm whether Jane should push directly or open a pull request.
6. After Azure and Huawei access are ready, add cloud credentials as sensitive Terraform Cloud variables.
