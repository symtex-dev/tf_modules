# Microsoft Entra security group

Creates a security-enabled, mail-disabled Microsoft Entra group and manages its
members. The Terraform execution identity is always included as a group owner;
additional owners can be supplied. This module creates the group only: it does
not grant Azure RBAC permissions.

```hcl
module "acr_developers" {
  source = "git::https://github.com/symtex-dev/tf_modules.git//azuread/security-group"

  name        = "acr-developers"
  description = "Developers allowed to push and pull container images"
  members     = [var.developer_one_object_id, var.developer_two_object_id]
}

module "acr_push" {
  source = "git::https://github.com/symtex-dev/tf_modules.git//azuread/iam/acrPush-contributor"

  assignments = {
    developers = {
      scope        = var.container_registry_id
      principal_id = module.acr_developers.object_id
    }
  }
}
```

The ACR role assignment is separate so the same group module can be reused for
other access needs. `AcrPush` allows pulling and pushing when the registry uses
the **RBAC Registry Permissions** mode. For **RBAC + ABAC Repository
Permissions** mode, use a repository role such as `Container Registry
Repository Writer` instead; the included `acrPush-contributor` module assigns
`AcrPush` and is not for that mode.

## Inputs and outputs

- `name` (required): group display name; must not be blank.
- `description` (optional): group description.
- `owners` (optional, default `[]`): additional owner object IDs; the Terraform
  execution identity is always an owner.
- `members` (optional, default `[]`): object IDs of users, groups, or service
  principals to add to the group.
- `object_id`: group object ID, for example to pass as an Azure role assignment's
  `principal_id`.
- `id`: provider resource ID for the group.
- `display_name`: created group's display name.

The identity running Terraform must have Microsoft Graph permissions to create
groups and manage the requested owners and members, and tenant policy must allow
group creation. Configure `hashicorp/azuread ~> 3.0` in the calling root.

## Verify

```sh
terraform init -backend=false
terraform validate
terraform test
```

Tests use a mocked AzureAD provider and require Terraform >= 1.7. They do not
authenticate to Microsoft Entra or create real groups.
