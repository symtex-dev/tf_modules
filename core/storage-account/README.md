# Storage account

Creates a Standard StorageV2 account in an existing resource group. Requires
Terraform >= 1.6 and AzureRM 4.x; configure the provider in the caller.

```hcl
module "storage" {
  source = "git::https://github.com/<ORG>/<REPO>.git//core/storage-account"

  name                = "uniquestorage123"
  resource_group_name = "platform-rg"
  location            = "westeurope"
  replication_type    = "ZRS"
}
```

Required inputs: `name` (globally unique, 3-24 lowercase letters/digits),
`resource_group_name`, `location`. `replication_type` defaults to `LRS` and supports
`LRS`, `GRS`, `RAGRS`, `ZRS`, `GZRS`, and `RAGZRS` subject to regional availability.
`tags` defaults to `{}`.

HTTPS-only, minimum TLS 1.2, no public nested items, and default OAuth authentication
are enforced. `public_network_access_enabled` and `shared_access_key_enabled`
both default to `false`. Use Microsoft Entra data roles and a
[private endpoint](../private-endpoint/) with appropriate
[private DNS](../private-dns-zone/) for data access. Public networking can be
explicitly enabled, but anonymous blob access remains disabled. No containers or
data-plane resources are created; a private-only account needs private connectivity
before managing them. When managing storage data-plane resources with AzureRM,
configure `storage_use_azuread = true` on the calling provider and grant the
Terraform principal the required storage data roles. Enable shared keys only for
clients that require them.

Outputs: `id`, `name`, `primary_blob_endpoint`. No keys are exposed as outputs;
Terraform state must still be treated as sensitive.
