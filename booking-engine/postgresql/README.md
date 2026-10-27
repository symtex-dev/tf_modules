# Low-cost Azure PostgreSQL

Azure PostgreSQL Flexible Server with `B_Standard_B1ms` (1 vCore, 2 GiB RAM),
32 GiB storage, seven-day backup retention, no high availability, and no
geo-redundant backups. These are the lowest-cost baseline settings, not a
guaranteed regional price. Check regional SKU availability and Azure pricing
before applying. Burstable compute is suitable for light workloads.

Storage auto-growth is disabled to limit unexpected storage charges. Monitor
free space: a full disk can make the server read-only. Compute and storage are
billed separately; stopping the server still incurs storage charges, and Azure
automatically restarts a stopped server after seven days.

## Terragrunt example

Place a `terragrunt.hcl` under `live/staging/postgresql`:

```hcl
terraform {
  source = "../../../module/postgresql"
}

include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

remote_state {
  backend = include.root.remote_state.backend
  config = merge(include.root.remote_state.config, {
    key = "${include.root.locals.prefix}/staging/postgresql/terraform.state"
  })
}

dependency "rg" {
  config_path = "../core/resource_group"
  mock_outputs_allowed_terraform_commands = ["init", "plan", "validate"]
  mock_outputs = {
    name = "mock-resource-group"
  }
}

inputs = {
  name                   = "smtx-testbooking-staging-pg"
  resource_group_name    = dependency.rg.outputs.name
  location               = include.root.locals.location
  zone                   = "2" # Keep the server in UK South availability zone 2.
  administrator_password = get_env("POSTGRES_ADMIN_PASSWORD")
  database_name          = "booking"

  firewall_rules = {
    application = {
      start_ip_address = get_env("APP_OUTBOUND_IP")
      end_ip_address   = get_env("APP_OUTBOUND_IP")
    }
  }
}
```

Supply the password through your shell or CI secret store. It is marked
sensitive but still stored in Terraform state; restrict access to the state
backend. No password or connection string is exported by this module.

Public network access is enabled by default. Set `public_network_access_enabled`
to `false` to require private networking. To create a private endpoint, provide
both network IDs:

```hcl
inputs = {
  # Other PostgreSQL inputs...
  public_network_access_enabled = false
  private_endpoint = {
    virtual_network_id = dependency.network.outputs.virtual_network_id
    subnet_id          = dependency.network.outputs.private_endpoint_subnet_id
  }
}
```

The module creates the PostgreSQL private DNS zone, links it to the supplied
VNet, and connects the private endpoint to the Flexible Server it creates. The
endpoint subnet must be in that VNet and meet Azure Private Endpoint subnet
requirements. If `private_endpoint` is omitted, no private DNS or endpoint
resources are created.

The AzureRM provider configuration is inherited from the caller. Run
`terragrunt plan` and review costs and changes before `terragrunt apply`.
The optional `zone` input pins a server to an availability zone. When adopting
this setting for an existing server, confirm the plan preserves its current
zone; changing zones is not an ordinary in-place update.

## Terraform expressions in this module

`count = var.database_name == null ? 0 : 1` means no database when its name is
omitted, otherwise one. The optional private endpoint, private DNS zone, and
VNet link share the same zero-or-one condition. `[0]` selects the first and
only instance when enabled; it is an index, not an Azure resource ID.

`for_each = var.firewall_rules` creates a rule per map entry; `each.key` names
it and `each.value` supplies its IP range. An empty map creates no rules.
The database output uses `try(...[0].name, null)` so the absent database
returns null rather than an invalid-index error.

`private_connection_resource_id = azurerm_postgresql_flexible_server.this.id`
targets the server created here and gives Terraform a dependency on it.
Creating the endpoint does not integrate Container Apps into the VNet or
configure clients' DNS. This module owns a private DNS zone when enabled;
coordinate ownership if multiple servers share a resource group or DNS setup.