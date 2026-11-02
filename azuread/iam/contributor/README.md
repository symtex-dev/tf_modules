# Contributor

Assigns the Azure RBAC **Contributor** role, which can manage resources but
cannot grant access. It does not grant blob data access.
Uses the shared [role-assignment module](../../../core/role-assignment/).

```hcl
module "contributor" {
  source = "git::https://github.com/symtex-dev/tf_modules.git//azuread/iam/contributor"

  assignments = {
    developers = {
      scope        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example"
      principal_id = "11111111-1111-1111-1111-111111111111"
    }
  }
}
```

See the [IAM documentation](../README.md) for inputs, outputs, permissions,
provider configuration, and tests.
