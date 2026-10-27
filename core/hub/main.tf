module "resource_group" {
  source = "../resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "vnet" {
  source = "../vnet"

  name                = var.name
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}

module "nsg" {
  source = "../nsg"

  name                = "${var.name}-nsg"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = var.tags
}

module "security_rules" {
  source = "../security-rule"

  resource_group_name         = module.resource_group.name
  network_security_group_name = module.nsg.name
  rules                       = var.security_rules
}

module "route_table" {
  source   = "../route-table"
  for_each = var.route_table == null ? {} : { network = var.route_table }

  name                          = "${var.name}-rt"
  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  bgp_route_propagation_enabled = each.value.bgp_route_propagation_enabled
  routes                        = each.value.routes
  tags                          = var.tags
}

module "subnets" {
  source   = "../subnet"
  for_each = var.subnets

  name                              = each.key
  resource_group_name               = module.resource_group.name
  virtual_network_name              = module.vnet.name
  address_prefixes                  = each.value.address_prefixes
  service_endpoints                 = each.value.service_endpoints
  delegations                       = each.value.delegations
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
  network_security_group            = each.value.associate_nsg ? { id = module.nsg.id } : null
  route_table                       = var.route_table != null && each.value.associate_route_table ? { id = module.route_table["network"].id } : null
}

module "gateway_subnet" {
  source   = "../subnet"
  for_each = var.vpn == null ? {} : { gateway = var.vpn }

  name                 = "GatewaySubnet"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.name
  address_prefixes     = each.value.gateway_subnet_prefixes
}

module "vpn" {
  source = "../peer-vpn"
  providers = {
    azurerm        = azurerm
    azurerm.remote = azurerm
  }

  vpn_gateway = var.vpn == null ? null : {
    name                = "${var.name}-vpn"
    resource_group_name = module.resource_group.name
    location            = module.resource_group.location
    subnet_id           = module.gateway_subnet["gateway"].id
    sku                 = var.vpn.sku
    generation          = var.vpn.generation
    public_ip_zones     = var.vpn.public_ip_zones
  }
  vpn_connections = var.vpn_connections
  vpn_shared_keys = var.vpn_shared_keys
  tags            = var.tags
}