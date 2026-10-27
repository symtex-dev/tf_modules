# Private endpoint

Creates a Private Link endpoint for an existing Azure resource and optionally
associates existing private DNS zones. Requires Terraform >= 1.6 and AzureRM 4.x;
configure the provider in the caller.

```hcl
module "blob_endpoint" {
  source = "git::https://github.com/<ORG>/<REPO>.git//core/private-endpoint"

  name                           = "storage-blob-pe"
  resource_group_name            = "platform-rg"
  location                       = "westeurope"
  subnet_id                      = module.spoke.subnet_ids["private-endpoints"]
  private_connection_resource_id = module.storage.id
  subresource_names              = ["blob"]
  private_dns_zone_ids            = [module.blob_dns.id]
}
```

Required inputs: `name`, `resource_group_name`, `location`, `subnet_id`,
`private_connection_resource_id`, and non-empty `subresource_names`.
Group IDs depend on the target service (for example `blob` or `vault`); most
services expect one group ID per endpoint. Use separate endpoints where required.
`private_dns_zone_ids` defaults to `[]` (no DNS zone group), and `tags` to `{}`.
`is_manual_connection` defaults to `false`; set it to `true` and optionally supply
`request_message` for an owner-approved connection. Do not set `request_message`
for automatic connections.

Outputs: `id`, `private_ip_address`. Ensure region/subnet compatibility, correct
subnet network policies, available address space, and service-specific DNS zones.
This module does not disable public access on the target resource or create VNet
links. Use the [private DNS zone module](../private-dns-zone/) for links, or arrange
DNS externally when omitting the DNS zone group.
