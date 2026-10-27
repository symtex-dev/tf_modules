# Azure DNS Zone Module

Creates a public Azure DNS zone with optional TXT and MX records.
The resource group must already exist.

## Outputs

| Name | Description |
| --- | --- |
| `dns_zone_id` | Resource ID of the zone. |
| `dns_zone_name` | Zone name, such as `domain.com`. |
| `resource_group_name` | Resource group containing the zone. |
| `name_servers` | Azure nameservers to configure at the domain registrar. |
| `txt_record_id` | TXT record ID, or `null` when disabled. |
| `mx_record_id` | MX record ID, or `null` when disabled. |

## Static website integration

Use this module's `dns_zone_name` and `resource_group_name` outputs for the
static website module's `custom_domain.zone_name` and
`custom_domain.resource_group_name` inputs. The website module creates its CNAME;
this module continues to own the zone and optional TXT/MX records.

See the [Terragrunt dependency example](../static-website/README.md#terragrunt-with-the-dns-zone-module)
for separate DNS and website units, deployment ordering, and registrar delegation.
If upgrading an existing unit, apply it to save the new outputs before using them
in a downstream dependency.
