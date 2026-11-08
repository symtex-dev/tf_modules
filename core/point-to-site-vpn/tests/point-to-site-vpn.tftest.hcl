mock_provider "azurerm" {
  mock_resource "azurerm_subnet" {
    defaults = {
      id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworks/hub-vnet/subnets/GatewaySubnet"
    }
  }

  mock_resource "azurerm_public_ip" {
    defaults = {
      id         = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/hub-rg/providers/Microsoft.Network/publicIPAddresses/hub-p2s-vpn-pip"
      ip_address = "203.0.113.10"
    }
  }

  mock_resource "azurerm_virtual_network_gateway" {
    defaults = {
      id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/hub-rg/providers/Microsoft.Network/virtualNetworkGateways/hub-p2s-vpn"
    }
  }
}

variables {
  name                  = "hub-p2s-vpn"
  resource_group_name   = "hub-rg"
  location              = "westeurope"
  virtual_network_name  = "hub-vnet"
  gateway_subnet_prefix = "10.0.255.0/27"
  client_address_pool   = ["172.20.0.0/24"]
  tenant_id             = "11111111-2222-3333-4444-555555555555"
}

run "configure_entra_openvpn" {
  command = apply

  assert {
    condition = (
      azurerm_virtual_network_gateway.this.type == "Vpn" &&
      azurerm_virtual_network_gateway.this.vpn_type == "RouteBased" &&
      azurerm_virtual_network_gateway.this.sku == "VpnGw1" &&
      azurerm_virtual_network_gateway.this.generation == "Generation1"
    )
    error_message = "The module must create a route-based VPN gateway with the supported default SKU."
  }

  assert {
    condition = (
      length(azurerm_virtual_network_gateway.this.vpn_client_configuration[0].address_space) == 1 &&
      azurerm_virtual_network_gateway.this.vpn_client_configuration[0].address_space[0] == "172.20.0.0/24"
    )
    error_message = "P2S clients must use the requested address pool."
  }

  assert {
    condition     = contains(azurerm_virtual_network_gateway.this.vpn_client_configuration[0].vpn_client_protocols, "OpenVPN")
    error_message = "P2S clients must use OpenVPN."
  }

  assert {
    condition     = contains(azurerm_virtual_network_gateway.this.vpn_client_configuration[0].vpn_auth_types, "AAD")
    error_message = "P2S clients must use Microsoft Entra authentication."
  }

  assert {
    condition = (
      azurerm_virtual_network_gateway.this.vpn_client_configuration[0].aad_tenant == "https://login.microsoftonline.com/11111111-2222-3333-4444-555555555555" &&
      azurerm_virtual_network_gateway.this.vpn_client_configuration[0].aad_issuer == "https://sts.windows.net/11111111-2222-3333-4444-555555555555/" &&
      azurerm_virtual_network_gateway.this.vpn_client_configuration[0].aad_audience == "c632b3df-fb67-4d84-bdcf-b95ad541b5c8"
    )
    error_message = "P2S clients must use the Microsoft-registered Entra client."
  }

  assert {
    condition = (
      azurerm_virtual_network_gateway.this.ip_configuration[0].subnet_id == module.gateway_subnet.id &&
      azurerm_virtual_network_gateway.this.ip_configuration[0].public_ip_address_id == azurerm_public_ip.this.id &&
      module.gateway_subnet.id == output.gateway_subnet_id
    )
    error_message = "The gateway must use the dedicated GatewaySubnet and Standard public IP."
  }

  assert {
    condition = (
      length(output.client_address_pool) == 1 &&
      output.client_address_pool[0] == "172.20.0.0/24"
    )
    error_message = "The module must expose the configured client address pool."
  }
}

run "reject_small_gateway_subnet" {
  command = plan

  variables {
    gateway_subnet_prefix = "10.0.255.0/28"
  }

  expect_failures = [var.gateway_subnet_prefix]
}

run "reject_invalid_client_pool" {
  command = plan

  variables {
    client_address_pool = ["not-a-cidr"]
  }

  expect_failures = [var.client_address_pool]
}
