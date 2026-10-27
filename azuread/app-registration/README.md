# App registration with OIDC federation

Creates a single-tenant Microsoft Entra application, its service principal, and
1-20 federated identity credentials. No client secrets or Azure RBAC assignments
are created. The Terraform execution identity is included as an owner of both
the application and service principal, alongside any additional `owners`.

## Terragrunt example

From a new unit at `live/platform/management/app-registration/terragrunt.hcl`:

```hcl
terraform {
  source = "../../../../modules/app-registration"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  name        = "smtx-landing-zone-ci"
  description = "GitHub Actions infrastructure deployment identity"

  federated_credentials = {
    github-plan = {
      issuer  = "https://token.actions.githubusercontent.com"
      subject = "repo:symtex-dev/smtx_landing_zone:environment:azure-plan"
    }
    github-apply = {
      issuer  = "https://token.actions.githubusercontent.com"
      subject = "repo:symtex-dev/smtx_landing_zone:environment:azure-apply"
    }
  }
}
```

`audiences` defaults to `["api://AzureADTokenExchange"]` on each credential.
Issuer and subject matching is exact and case-sensitive; use the environment
subject above only when the GitHub job declares that environment. Branch-based
subjects instead look like `repo:OWNER/REPO:ref:refs/heads/main`.

The module requires `hashicorp/azuread ~> 3.0`, not the AzureRM provider. Configure
the AzureAD provider in the calling root when needed; otherwise it uses the
default configuration and supports Azure CLI authentication or the existing
`ARM_TENANT_ID`, `ARM_CLIENT_ID`, and `ARM_USE_OIDC` environment variables in CI.
Use the target tenant explicitly when operating across multiple tenants.

The identity creating these resources needs Microsoft Graph application
permission `Application.ReadWrite.OwnedBy` (with admin consent), or broader
`Application.ReadWrite.All`. Additional user owners can require `User.Read.All`.
An Azure subscription Contributor role alone does not grant these directory
permissions. Bootstrap with an already authorized identity; a new app cannot
create its own initial trust.

Set `AZURE_CLIENT_ID` and `AZURE_TENANT_ID` from the `client_id` and `tenant_id`
outputs. Assign least-privilege Azure roles separately using
`service_principal_object_id`, including state-container access if needed. OIDC
trust allows authentication but does not itself grant Azure resource access.
Protect the GitHub environments and configure approval rules separately. The
example uses one app for both environments; use separate module instances and
role assignments when plan/apply identities must have different permissions.

## Local checks

```bash
terraform init -backend=false
terraform validate
terraform test
```

Tests use a mocked AzureAD provider and require Terraform >= 1.7. They do not
authenticate to Microsoft Entra or create resources.