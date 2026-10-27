output "id" {
  description = "The ID of the resource group."
  value       = azurerm_static_web_app.this.id
}

output "name" {
  description = "The name of the resource group."
  value       = azurerm_static_web_app.this.name
}

output "location" {
  description = "The location of the resource group."
  value       = azurerm_static_web_app.this.location
}

output "default_host_name" {
  description = "Default hostname of the static web app."
  value       = azurerm_static_web_app.this.default_host_name
}

output "custom_domain_name" {
  description = "Custom domain registered with the static web app, or null when disabled."
  value       = var.custom_domain == null ? null : azurerm_static_web_app_custom_domain.this[0].domain_name
}
