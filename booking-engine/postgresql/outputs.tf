output "server_id" {
  description = "ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "server_name" {
  description = "PostgreSQL Flexible Server name."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "server_fqdn" {
  description = "PostgreSQL hostname. Connect on port 5432 with TLS enabled."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_name" {
  description = "Application database name, or null when none was requested."
  # With count = 0 there is no [0]; try() turns that index error into null.
  value       = try(azurerm_postgresql_flexible_server_database.this[0].name, null)
}