# Network security rule module

This is the shared implementation used by composed network modules.

Creates standalone rules in an existing NSG. Inputs identify the resource
group, NSG name, and a `rules` map. An empty map creates no rules. Each map key
is both the Azure rule name and Terraform's instance key. `each.value` supplies
the priority, direction, access, protocol, and source/destination selectors.
The `ids` output maps rule names to their Azure IDs.

Validation checks priority range and integer values, supported option values,
and exactly one selector for each source/destination port and address. The
expression `[for selector in [...] : selector if selector]` keeps only true
values; `length(...) == 1` means exactly one option was provided.

Another validation builds strings such as `Inbound:100` for every rule.
`distinct` removes duplicates; comparing its length with the original rule
count rejects duplicate priorities within the same direction. The same
priority can still appear once inbound and once outbound.

Do not mix these standalone resources with inline rules managed on the same
NSG, because the two definitions can overwrite each other.