output "workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = azurerm_log_analytics_workspace.this.id
}

output "application_insights_id" {
  description = "Application Insights resource ID."
  value       = azurerm_application_insights.this.id
}

output "connection_string" {
  description = "Application Insights connection string for application telemetry."
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}
