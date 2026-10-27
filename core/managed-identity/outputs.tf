output "id" {
  description = "Managed identity resource ID."
  value       = azurerm_user_assigned_identity.this.id
}

output "principal_id" {
  description = "Service principal object ID for role assignments."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "client_id" {
  description = "Client ID for workload authentication."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "tenant_id" {
  description = "Microsoft Entra tenant ID."
  value       = azurerm_user_assigned_identity.this.tenant_id
}
