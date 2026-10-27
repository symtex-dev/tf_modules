output "job_id" {
  description = "ID of the migration Container Apps Job."
  value       = azurerm_container_app_job.this.id
}

output "job_name" {
  description = "Name of the migration Container Apps Job."
  value       = azurerm_container_app_job.this.name
}