# Owners

Assigns the Azure RBAC **Owner** role, which can manage resources and grant
access at the supplied scope. This is not a Microsoft Entra directory role.
Uses the shared [role-assignment module](../../../core/role-assignment/).

```hcl
module "owners" {
  source = "git::https://github.com/symtex-dev/tf_modules.git//azuread/iam/owners"

  assignments = {
    administrators = {
      scope        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example"
      principal_id = "11111111-1111-1111-1111-111111111111"
    }
  }
}
```

See the [IAM documentation](../README.md) for inputs, outputs, permissions,
provider configuration, and tests.
