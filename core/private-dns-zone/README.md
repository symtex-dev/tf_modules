# Private DNS zone

Creates a private DNS zone and optional VNet links, distinct from the existing
public DNS module. Requires Terraform >= 1.6 and AzureRM 4.x; configure the provider
in the caller.

```hcl
module "blob_dns" {
  source = "git::https://github.com/<ORG>/<REPO>.git//core/private-dns-zone"

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "platform-rg"
  virtual_network_links = {
    spoke = { virtual_network_id = module.spoke.vnet_id }
  }
}
```

Required inputs: `name`, `resource_group_name`. `virtual_network_links` defaults to
`{}` and takes stable link names mapped to `virtual_network_id` and optional
`registration_enabled` (default `false`). Keep auto-registration disabled for
Private Link zones. `tags` defaults to `{}`.

Outputs: `id`, `name`, `virtual_network_link_ids`. Pass `id` to a
[private endpoint](../private-endpoint/) to register its DNS records.
Use the zone name appropriate to the target service and cloud. Reuse an existing
zone instead of linking multiple zones with the same namespace to one VNet.
Custom/on-premises DNS clients may require forwarding through Azure DNS Private
Resolver or a DNS forwarder; VNet peering alone does not configure DNS forwarding.
