# Virtual network module

This is the shared implementation used by composed network modules.

Creates one Azure VNet in an existing resource group. Required inputs are
`name`, `resource_group_name`, `location`, and `address_space`. Optional
`dns_servers` and `tags` customize DNS and metadata. Subnets and peerings are
created by other modules.

Address validation uses `[for prefix in var.address_space : ...]` to test every
CIDR. `can(cidrhost(prefix, 0))` returns false for malformed CIDRs rather than
raising a parsing error; `alltrue` requires all checks to pass and `length`
requires at least one range. This does not detect overlap with remote VNets.

Outputs are `id`, `name`, and `address_space`, not `vnet_name`. Callers must use
the exact exported names. Subnet ranges must be inside this VNet, for example
`10.0.1.0/24` inside `10.0.0.0/16`.