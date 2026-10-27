resource "azurerm_virtual_network_peering" "local_to_remote" {
  for_each = var.peering == null ? {} : { connection = var.peering }

  name                         = each.value.local_to_remote_name
  resource_group_name          = each.value.local_resource_group_name
  virtual_network_name         = each.value.local_virtual_network_name
  remote_virtual_network_id    = each.value.remote_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = false
  use_remote_gateways          = each.value.use_remote_gateways

  depends_on = [azurerm_virtual_network_peering.remote_to_local]
}

resource "azurerm_virtual_network_peering" "remote_to_local" {
  provider = azurerm.remote
  for_each = var.peering == null ? {} : { connection = var.peering }

  name                         = each.value.remote_to_local_name
  resource_group_name          = each.value.remote_resource_group_name
  virtual_network_name         = each.value.remote_virtual_network_name
  remote_virtual_network_id    = each.value.local_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.use_remote_gateways
  use_remote_gateways          = false
}

resource "azurerm_public_ip" "vpn" {
  for_each = var.vpn_gateway == null ? {} : { gateway = var.vpn_gateway }

  name                = "${each.value.name}-pip"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = each.value.public_ip_zones
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "this" {
  for_each = var.vpn_gateway == null ? {} : { gateway = var.vpn_gateway }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = each.value.sku
  generation          = each.value.generation
  active_active       = false
  enable_bgp          = false
  tags                = var.tags

  ip_configuration {
    name                          = "gateway"
    public_ip_address_id          = azurerm_public_ip.vpn[each.key].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = each.value.subnet_id
  }
}

resource "azurerm_local_network_gateway" "this" {
  for_each = var.vpn_connections

  name                = each.key
  resource_group_name = try(var.vpn_gateway.resource_group_name, "")
  location            = try(var.vpn_gateway.location, "")
  gateway_address     = each.value.gateway_address
  gateway_fqdn        = each.value.gateway_fqdn
  address_space       = each.value.address_space
  tags                = var.tags

  lifecycle {
    precondition {
      condition     = var.vpn_gateway != null
      error_message = "VPN connections require vpn_gateway configuration."
    }
  }
}

resource "azurerm_virtual_network_gateway_connection" "this" {
  for_each = var.vpn_connections

  name                       = "${each.key}-connection"
  resource_group_name        = try(var.vpn_gateway.resource_group_name, "")
  location                   = try(var.vpn_gateway.location, "")
  type                       = "IPsec"
  virtual_network_gateway_id = try(azurerm_virtual_network_gateway.this["gateway"].id, null)
  local_network_gateway_id   = azurerm_local_network_gateway.this[each.key].id
  shared_key                 = lookup(var.vpn_shared_keys, each.key, null)
  connection_protocol        = each.value.connection_protocol
  enable_bgp                 = false
  tags                       = var.tags

  lifecycle {
    precondition {
      condition     = contains(keys(var.vpn_shared_keys), each.key)
      error_message = "Provide a VPN shared key for every connection name."
    }
  }
}