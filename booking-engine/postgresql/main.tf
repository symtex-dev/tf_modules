
resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  zone                          = var.zone
  version                       = var.postgresql_version
  administrator_login           = var.administrator_login
  administrator_password        = var.administrator_password
  sku_name                      = var.sku_name
  storage_mb                    = var.storage_mb
  auto_grow_enabled             = false
  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  # count chooses zero or one database. Counted resources use numeric indexes.
  count     = var.database_name == null ? 0 : 1
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "this" {
  # Each map key creates a named IPv4 allowlist rule; an empty map creates none.
  for_each         = var.firewall_rules
  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}



#########################################
#PRIVATE ENDPOINT
#########################################


resource "azurerm_private_dns_zone" "postgres" {
  # The same condition enables the DNS zone, VNet link, and endpoint together.
  count               = var.private_endpoint == null ? 0 : 1
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  count               = var.private_endpoint == null ? 0 : 1
  name                = "postgres-dns-link"
  resource_group_name = var.resource_group_name
  # [0] selects the sole zone created when count is 1; this link shares its count.
  private_dns_zone_name = azurerm_private_dns_zone.postgres[0].name
  virtual_network_id    = var.private_endpoint.virtual_network_id
}

resource "azurerm_private_endpoint" "postgres" {
  count               = var.private_endpoint == null ? 0 : 1
  name                = "pe-postgres"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = "postgres-connection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.this.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "postgres-dns-zone-group"
    private_dns_zone_ids = [
      azurerm_private_dns_zone.postgres[0].id
    ]
  }
}