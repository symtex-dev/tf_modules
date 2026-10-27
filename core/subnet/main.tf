resource "azurerm_subnet" "this" {
  name                              = var.name
  resource_group_name               = var.resource_group_name
  virtual_network_name              = var.virtual_network_name
  address_prefixes                  = var.address_prefixes
  service_endpoints                 = var.service_endpoints
  private_endpoint_network_policies = var.private_endpoint_network_policies

  dynamic "delegation" {
    for_each = var.delegations

    content {
      name = delegation.key

      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.network_security_group == null ? {} : { attachment = var.network_security_group }

  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = each.value.id
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = var.route_table == null ? {} : { attachment = var.route_table }

  subnet_id      = azurerm_subnet.this.id
  route_table_id = each.value.id
}