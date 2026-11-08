# Point-to-site VPN gateway

Creates an Azure route-based VPN gateway and Standard public IP in an existing
hub VNet. It also creates the dedicated `GatewaySubnet`. Point-to-site clients
authenticate with Microsoft Entra ID over OpenVPN using the Microsoft-registered
Azure VPN Client application; no custom app registration or client certificate
is needed.

The module does not create the resource group, hub VNet, VM, or SOCKS5 service.
It assumes there is no VPN gateway or `GatewaySubnet` in the VNet already. Azure
supports only one VPN gateway per VNet; do not use this module alongside a
gateway managed by `core/hub` or another module in the same VNet.

```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

module "p2s_vpn" {
  source = "git::https://github.com/<ORG>/<REPO>.git//core/point-to-site-vpn"

  name                = "hub-p2s-vpn"
  resource_group_name = "hub-rg"
  location            = "westeurope"
  virtual_network_name = "hub-vnet"

  gateway_subnet_prefix = "10.0.255.0/27"
  client_address_pool   = ["172.20.0.0/24"]
  tenant_id             = var.tenant_id

  tags = {
    environment = "production"
  }
}
```

Choose a `GatewaySubnet` CIDR inside the hub VNet address space. The gateway
subnet must be /27 or larger, must not overlap any other subnet, and must not
have an NSG or route table attached. Choose a client address pool that does not
overlap the hub VNet, other connected networks, or client networks. Change the
default `VpnGw1` SKU if its capacity or availability is not appropriate; gateway
provisioning can take a while and incurs ongoing Azure charges.

## Use Chrome through a VM SOCKS5 proxy

After the gateway is provisioned:

1. In the Azure portal, open the VPN gateway's **Point-to-site configuration**
   and download the VPN client profile. Import it into Azure VPN Client on the
   local computer and sign in with the intended Microsoft Entra account.
2. Ensure the Packer-built VM is on the hub VNet and the SOCKS5 service listens
   on its private interface.
3. Configure the VM subnet's NSG to allow the SOCKS5 port only from
   `client_address_pool`. Allow SSH only from the VPN client pool if SSH access
   is needed. Do not expose the SOCKS5 or SSH ports to the public internet.
4. Configure Chrome to use the VM's private IP address and SOCKS5 port. The
   computer must be connected to the P2S VPN while using the proxy.

This module provides the P2S connection to the hub VNet only. It does not create
spoke peering, configure DNS, or grant access to VM ports; configure those
separately if needed. A VPN connection provides network reachability, not VM
authentication. Secure and authenticate the SOCKS5 service independently.

## Inputs and outputs

- `name`, `resource_group_name`, `location`, `virtual_network_name`: gateway
  identity and the existing hub VNet location.
- `gateway_subnet_prefix`: IPv4 range for the new, dedicated `GatewaySubnet`.
- `client_address_pool`: one or more non-overlapping IPv4 ranges for VPN clients.
- `tenant_id`: Microsoft Entra tenant GUID.
- `sku` / `generation`: defaults to `VpnGw1` / `Generation1`.
- `public_ip_zones`: optional zones for the Standard public IP.
- `tags`: optional tags.
- `vpn_gateway_id`, `gateway_subnet_id`, `public_ip_address`, and
  `client_address_pool`: outputs for downstream configuration.

## Verify

```sh
terraform init -backend=false
terraform validate
terraform test
```

Tests use a mocked AzureRM provider and require Terraform >= 1.7. They do not
authenticate to Azure or deploy resources.
