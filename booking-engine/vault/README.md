# Key Vault module

Creates an Azure Key Vault from `name`, `location`, `resource_group_name`, and
`tenant_id`. Inputs also control SKU, soft-delete retention, purge protection,
deployment integration flags, and tags. Outputs are `id`, `name`, and
`vault_uri`.

`contains(["standard", "premium"], var.sku_name)` validates the supplied SKU
against the supported names. Variable defaults supply values when callers
omit optional settings; they do not automatically create any secrets.

This module does not create secret values, access policies, RBAC assignments,
private endpoints, or network restrictions. Creating a vault does not grant
the application permission to read it. Deployment integration flags are not
a replacement for application data-access permissions. Purge protection and
soft-delete settings affect recovery and deletion; review them before apply.