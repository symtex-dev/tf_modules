# Managed identity

Creates a user-assigned managed identity in an existing resource group.
Requires Terraform >= 1.6 and AzureRM 4.x; configure the provider in the caller.

```hcl
module "identity" {
  source = "git::https://github.com/<ORG>/<REPO>.git//core/managed-identity"

  name                = "worker-identity"
  resource_group_name = "platform-rg"
  location            = "westeurope"
  tags                = { environment = "dev" }
}
```

Required inputs: `name`, `resource_group_name`, `location`. `tags` defaults to `{}`.
Outputs: `id`, `client_id`, `principal_id`, `tenant_id`.
Attach `id` to a compatible workload; use `principal_id` with the
[role-assignment module](../role-assignment/). Creating an identity does not grant
permissions or automatically attach it to a workload.
