# Resource group module

This is the shared implementation for Azure resource groups.

Creates one Azure resource group from `name`, `location`, and optional `tags`.
Exports `id`, `name`, and `location` for downstream modules.

The required inputs are `name` and `location`; `tags` defaults to an empty map.
Outputs expose the resource group's Azure ID, name, and location.

The label `this` is Terraform's local name for the resource, not its Azure name.
The Azure name comes from `var.name`. The group is a management boundary; it
does not create networking, permissions, or applications. Destroying the group
can remove the resources inside it, so review plans carefully.