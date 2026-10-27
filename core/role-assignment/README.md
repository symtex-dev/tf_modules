# Role assignments

Creates Azure RBAC assignments using stable map keys, including when scopes and
principal IDs are outputs of other modules. Requires Terraform >= 1.6 and AzureRM
4.x; configure the provider in the caller.

```hcl
module "roles" {
  source = "git::https://github.com/<ORG>/<REPO>.git//core/role-assignment"

  assignments = {
    storage_reader = {
      scope                            = module.storage.id
      principal_id                     = module.identity.principal_id
      role_definition_name             = "Storage Blob Data Reader"
      skip_service_principal_aad_check = true
    }
  }
}
```

`assignments` defaults to `{}`. Each entry requires `scope` and `principal_id`
(Microsoft Entra object ID, not application client ID), and exactly one of
`role_definition_name` or `role_definition_id`. Use a fully scoped Azure role
definition ID for custom roles. `skip_service_principal_aad_check` defaults to
`false`; enable it only for service principals such as newly created managed
identities. The caller needs role assignment write permission on each scope.
RBAC propagation is not immediate.

Output `ids` maps input keys to role assignment resource IDs.
