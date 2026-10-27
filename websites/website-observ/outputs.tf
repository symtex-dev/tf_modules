output "app_insigts_connection_string" {
    value = azurerm_application_insights.main-observ.connection_string
    sensitive = true
  
}

output "log_analytics_workspace_id" {
    value = azurerm_log_analytics_workspace.main_workspace.id
  
}