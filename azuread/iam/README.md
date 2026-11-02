# IAM role modules

These modules assign built-in **Azure RBAC resource roles** to existing
Microsoft Entra users, groups, service principals, or managed identities.
They do not create identities, groups, custom role definitions, or Entra
directory role assignments. Despite their location under `azuread/`, they use
AzureRM, not the AzureAD provider.

| Module | Fixed role |
| --- | --- |
| [owners](./owners/) | Owner |
| [contributor](./contributor/) | Contributor |
| [blob-storage-owner](./blob-storage-owner/) | Storage Blob Data Owner |
| [blob-storage-contributor](./blob-storage-contributor/) | Storage Blob Data Contributor |

All four reuse [core/role-assignment](../../core/role-assignment/) and require
Terraform >= 1.6 and AzureRM 4.x. Configure the provider in the calling root:

```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
```

## Shared inputs and outputs

`assignments` is a map keyed by stable caller-chosen names, allowing scopes and
principal IDs to come from other module outputs. It defaults to `{}`, creating
no assignments.

Each entry accepts:

- `scope` (required): Azure resource ID, resource group ID, subscription ID, or
  management group ID. Prefer the narrowest scope needed.
- `principal_id` (required): Microsoft Entra object ID, not application client ID.
- `skip_service_principal_aad_check` (optional, default `false`): enable only
  for service principals, such as newly created managed identities.

The role is fixed by the selected module and is not an input. The shared module
rejects blank scopes and principal IDs. Output `ids` maps input keys to role
assignment resource IDs.

The caller needs role assignment write permission at every supplied scope.
RBAC propagation is not immediate. Blob roles do not bypass storage firewall
or private endpoint requirements.

## Verification

The shared test suite under `owners/tests` exercises all four modules using a
mocked AzureRM provider. Terraform >= 1.7 is required for tests; no credentials
or Azure deployments are needed.

```sh
terraform fmt -check -recursive azuread/iam
terraform -chdir=azuread/iam/owners init -backend=false
terraform -chdir=azuread/iam/owners validate
terraform -chdir=azuread/iam/owners test
```
