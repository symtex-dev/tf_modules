output "primary_web_endpoint" {
  description = "The primary web endpoint for the static website"
  value       = azurerm_storage_account.this.primary_web_endpoint
}

output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}
