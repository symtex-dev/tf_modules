output "id" {
  description = "Storage account resource ID."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage account name."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Blob service URL; private DNS resolves its hostname to a private endpoint when configured."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}
