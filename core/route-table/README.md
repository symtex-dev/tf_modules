# Route table module

This is the shared implementation used by composed network modules.

Creates a route table and zero or more user-defined routes. Supply `name`,
`resource_group_name`, `location`, and optionally `routes`,
`bgp_route_propagation_enabled`, and `tags`. A subnet association is separate
and is supported by the `subnet` module.

`for_each = var.routes` creates one route for each map entry. `each.key` is
its name, while `each.value` contains its CIDR and next-hop settings. An empty
map still creates the route table, but no custom route resources.

Validation uses `alltrue` to check every route. A conditional requires
`next_hop_in_ip_address` for `VirtualAppliance` and requires it to be null for
other next-hop types. Outputs are `id`, `name`, and `route_ids`. The latter is
a map built with a `for` expression, preserving the input route names as keys.

A default route such as `0.0.0.0/0` can redirect all outbound traffic. Review
the routing implications and next-hop availability before applying.