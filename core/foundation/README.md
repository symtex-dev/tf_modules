# Foundation

Composes sibling modules to create a resource group, user-assigned managed
identity, Log Analytics workspace, and workspace-backed Application Insights.
Optional blob storage grants the identity `Storage Blob Data Contributor` at the
storage-account scope. No subscription-wide roles are granted.

```hcl
provider "azurerm" {
  features {}
  subscription_id     = var.subscription_id
  storage_use_azuread  = true
}

module "foundation" {
  source = "git::https://github.com/<ORG>/<REPO>.git//core/foundation"

  name                = "platform-dev"
  resource_group_name = "platform-dev-rg"
  location            = "westeurope"
  tags                = { environment = "dev" }

  storage = {
    name = "uniquedevstorage123"
    private_endpoint = {
      subnet_id          = module.spoke.subnet_ids["private-endpoints"]
      virtual_network_id = module.spoke.vnet_id
    }
  }
}
```

The example assumes an existing `module.spoke` exposing subnet and VNet IDs.
See the [spoke outputs](../spoke/outputs.tf). Names must satisfy Azure resource
naming rules, and the storage name must be globally unique.

Omit `storage` (default `null`) to create only the resource group, identity, and
monitoring. With `storage.private_endpoint`, the module also composes
[private DNS](../private-dns-zone/) and a [private endpoint](../private-endpoint/)
for the blob service. The subnet must belong to the supplied VNet and support
private endpoints. Do not create a duplicate `privatelink.blob.core.windows.net`
zone for a VNet already linked to one; use standalone modules with the existing
zone instead. This convenience composition targets Azure public cloud DNS.

Storage public networking and shared-key authentication are disabled by default.
If you omit `private_endpoint`, arrange connectivity/DNS separately, or explicitly
enable `storage.public_network_access_enabled`. Only blob connectivity is created;
other storage services require their own private endpoints and DNS zones.

Attach `identity.id` to a workload and use `identity.client_id` for authentication.
RBAC propagation may delay initial access. Creating resources alone does not attach
the identity to an application or configure application telemetry.
Use the sensitive `application_insights_connection_string` output in your app.

Inputs include `name`, `resource_group_name`, `location`,
`log_retention_in_days` (default 30), optional `storage`, and `tags`.
Outputs include `resource_group`, `identity`, `workspace_id`,
`application_insights_id`, `application_insights_connection_string`, nullable
`storage`, `role_assignment_ids`, and nullable `storage_private_endpoint`.
There is no backend or provider configuration inside the module.

Requires Terraform >= 1.6 and AzureRM 4.x. Tests require Terraform >= 1.7:

```sh
terraform init -backend=false
terraform validate
terraform test
```

The tests mock AzureRM and exercise this composition and the standalone building
blocks without Azure access.
