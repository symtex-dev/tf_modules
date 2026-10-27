# Spoke network module

Composes the sibling modules into a VNet, NSG, security rules,
named subnets, optional route table, and optional peering to a hub. Required
inputs include `name`, `resource_group_name`, `location`, and `address_space`.
The resource group must already exist; this module no longer creates one.
The staging caller reads its name from the shared resource-group dependency.

The `removed` block relinquishes ownership of the old `module.resource_group`
without destroying its Azure resource group. It requires Terraform 1.7 or
newer. Keep it while older states may still contain that module. Resources
whose resource group changes can still be replaced; this is not an Azure
resource move. See the live core migration guide before applying to an
existing deployment. Remove the legacy group manually only after confirming
that no resources depend on or remain in it.

`for_each = var.subnets` creates a child subnet module per map key. Per-subnet
flags control NSG and route-table attachments. A conditional passes `{ id =
... }` when an attachment is requested, or null to omit it. The route table
itself is an optional child module keyed `network`; looking up
`module.route_table["network"].id` selects that instance.

If `hub` is null, no peering configuration is passed to the peering module.
Otherwise the module builds both directions' names and IDs. Its `providers`
map connects the child's `azurerm.remote` provider to the caller's
`azurerm.hub` provider. This lets the hub and spoke be managed in separate
subscriptions with the same deployment identity, provided it has permissions.

`optional(...)` in subnet object types supplies defaults for omitted fields.
Validation reserves `GatewaySubnet` and checks permitted network policy
values. Address ranges still need planning to avoid overlap with peered VNets.

Outputs include resource-group name, VNet ID/name, subnet IDs keyed by name,
NSG ID, optional route-table ID, and both optional peering IDs. `try` returns
null for an omitted route table; map comprehensions collect child subnet IDs.