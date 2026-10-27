output "container_app_id" {
  description = "ID of the Container App."
  value       = azurerm_container_app.this.id
}

output "container_app_name" {
  description = "Name of the Container App."
  value       = azurerm_container_app.this.name
}

output "container_app_latest_revision_fqdn" {
  description = "Latest revision FQDN when ingress is enabled; otherwise null."
  value       = try(azurerm_container_app.this.latest_revision_fqdn, null)
}

output "container_app_environment_id" {
  description = "ID of the Container Apps environment."
  value       = azurerm_container_app_environment.this.id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace used by the environment."
  value       = azurerm_log_analytics_workspace.this.id
}
