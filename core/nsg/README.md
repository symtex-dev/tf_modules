# Network security group module

This is the shared implementation used by composed network modules.

Creates one NSG using `name`, `resource_group_name`, `location`, and optional
`tags`. Outputs are `id` and `name`.

This module creates the group, not custom rules or subnet associations. Use
`security-rule` for named rules and `subnet` to attach the group. Azure supplies
default NSG rules even when this resource contains no custom rules. Creating
an unattached NSG does not filter a subnet's traffic.