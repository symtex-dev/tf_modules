# Peering and VPN module

This is the shared implementation used by composed network modules.

Supports optional two-way VNet peering, an optional route-based VPN gateway
with Standard public IP, and named site-to-site IPsec connections. These are
separate options: peering does not create a VPN gateway. A VPN gateway needs
an existing suitable `GatewaySubnet`. This module does not create that subnet.

`peering = null` creates neither peering. Otherwise a one-entry map keyed
`connection` creates each direction. The caller must provide both the default
AzureRM provider and the `azurerm.remote` alias; the latter manages the remote
network, potentially in another subscription. The remote-side peering is
created first. Using remote gateways requires an existing compatible hub
gateway and gateway-transit settings.

`vpn_gateway = null` omits the public IP and gateway. A supplied configuration
creates one of each under the shared key `gateway`. Each `vpn_connections`
entry creates a remote-site definition and a connection. Supply matching
`vpn_shared_keys` from a secret source; they are not repository configuration.

`try(...)` provides fallbacks when an optional gateway is absent. Lifecycle
preconditions then report missing gateway or shared-key configuration.
`lookup(var.vpn_shared_keys, each.key, null)` selects the secret for the current
connection; `contains(keys(...), each.key)` checks that its name exists.

Optional-resource outputs use `try(resource["key"].id, null)` so missing
instances return null. The connection output uses a map comprehension to
return IDs by connection name. Gateway resources incur Azure costs; shared
keys are sensitive and can be present in Terraform state.