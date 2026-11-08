locals {
  aad_tenant   = "https://login.microsoftonline.com/${var.tenant_id}"
  aad_issuer   = "https://sts.windows.net/${var.tenant_id}/"
  aad_audience = "c632b3df-fb67-4d84-bdcf-b95ad541b5c8"
}

module "gateway_subnet" {
  source = "../subnet"

  name                 = "GatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.gateway_subnet_prefix]
}

resource "azurerm_public_ip" "this" {
  name                = "${var.name}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.public_ip_zones
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = var.sku
  generation          = var.generation
  active_active       = false
  bgp_enabled         = false
  tags                = var.tags

  ip_configuration {
    name                          = "gateway"
    public_ip_address_id          = azurerm_public_ip.this.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.gateway_subnet.id
  }

  vpn_client_configuration {
    address_space        = var.client_address_pool
    vpn_client_protocols = ["OpenVPN"]
    vpn_auth_types       = ["AAD"]
    aad_tenant           = local.aad_tenant
    aad_issuer           = local.aad_issuer
    aad_audience         = local.aad_audience
  }
}
