# Reusable Terraform modules

These modules describe Azure resources; the calling root configuration supplies
environment-specific values and state settings. A module can be called more
than once with different inputs. Do not edit its copy in `.terragrunt-cache`.

## Module map

| Module | Responsibility |
| --- | --- |
| [resource-group](../modules/resource-group/README.md) | Resource group for related resources |
| [vnet](../modules/vnet/README.md) | Virtual network and its address space |
| [subnet](../modules/subnet/README.md) | Subnet, delegations, optional NSG/route attachments |
| [nsg](../modules/nsg/README.md) | Network security group container |
| [security-rule](../modules/security-rule/README.md) | Standalone rules in an existing NSG |
| [route-table](../modules/route-table/README.md) | Route table and named routes |
| [peer-vpn](../modules/peer-vpn/README.md) | Optional VNet peerings and VPN resources |
| [spoke](spoke/README.md) | Network composition inside the existing project resource group |
| [postgresql](postgresql/README.md) | Database server, optional DB and private endpoint |
| [container-app](container-app/README.md) | Container App, environment, and logs |
| [container-app-job](container-app-job/README.md) | Manually triggered migration job in an existing environment |
| [vault](vault/README.md) | Key Vault resource, not secret values |

## Reading Terraform

- `var.name` reads a module input; `local.name` reads a calculated local value.
- `resource_type.label.id` reads a resource attribute and creates a dependency.
- `module.label.output` reads a child module's exported output.
- `condition ? yes : no` is a conditional expression, not a function.
- `null` means no value; `{}` is an empty map; `[]` is an empty list.
- `for_each` creates one resource/module instance per map entry. `each.key`
  identifies the entry and `each.value` supplies its settings.
- `count` creates numbered instances. A one-instance resource uses `[0]`.
- `dynamic` repeats a nested block; it does not create a separate resource.
- `[for item in items : expression]` builds a list. A trailing `if` filters it.
- `{ for name, item in items : name => item.id }` builds a map of IDs by name.
- `optional(type, default)` gives an object field a default when omitted.
- `try(expression, fallback)` handles evaluation errors; it does not replace
  a valid null result. `coalesce(...)` selects the first non-null, non-empty string.
- `lookup(map, key, fallback)` safely reads a map entry.
- `can(expression)` reports whether evaluation succeeds. `alltrue(list)`
  requires every boolean to be true; an empty list passes.
- `contains(list, value)` checks membership. `keys` and `values` extract map parts.

Map keys are part of Terraform state addresses. Renaming one can destroy and
recreate a resource unless state is migrated. An unknown ID is fine as an
attribute, but `for_each` keys and resource counts must be known during planning.

Configure Azure credentials, provider selection, and the backend in the
calling root module. These reusable modules do not configure the Azure provider.