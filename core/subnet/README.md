# Subnet module

This is the shared implementation used by composed network modules.

Creates a subnet inside an existing Azure virtual network. It can optionally
delegate the subnet to Azure services, enable service endpoints, and attach a
network security group (NSG) or route table. It does not create the VNet, NSG,
or route table. Its CIDRs must fit inside the target VNet and not overlap other
subnets; validating CIDR syntax alone cannot check those Azure constraints.

Required inputs are `name`, `resource_group_name`, `virtual_network_name`, and
`address_prefixes`. Outputs are `id`, `name`, and `address_prefixes`.

## Optional associations explained

```hcl
for_each = var.route_table == null ? {} : { attachment = var.route_table }
```

This is a conditional expression, not a function call. Read it as: "If no route
table was supplied, create nothing; otherwise create one association."

- `var.route_table` reads the module input.
- `== null` checks whether that input was omitted or explicitly set to null.
- `condition ? first : second` chooses the first value when true, otherwise the second.
- `{}` is an empty map, so `for_each` creates zero resource instances.
- `{ attachment = var.route_table }` is a map with one entry, so it creates one.
- `attachment` is the entry's stable key. The instance address ends in
  `this["attachment"]`; it is not the Azure route table's name.
- `each.value.id` reads the `id` field from the supplied object.

For example, pass `route_table = { id = dependency.routes.outputs.id }` in a
Terragrunt caller. Wrapping the ID in an object lets Terraform know that one
association is requested even when the ID itself is not known until apply.
The caller must still make the object's presence known during planning.

## Other expressions

`dynamic "delegation"` generates a nested delegation block for each entry in
`var.delegations`; its map key is the delegation name and its value supplies
the Azure service name and actions. An empty map generates no blocks.

The address validation uses a list comprehension (`[for ... : ...]`) to test
each prefix. `cidrhost(prefix, 0)` parses the CIDR, `can(...)` returns false if
parsing fails, and `alltrue(...)` requires every prefix to pass. `length(...)`
also prevents an empty list. `optional(list(string), [])` makes delegation
actions optional, defaulting to an empty list.