resource "azurerm_log_analytics_workspace" "main_workspace" {
  name = "${var.prefix}-log-workspace"
  resource_group_name = var.resource_group_name
  location = var.location

}

resource "azurerm_application_insights" "main-observ" {
  name = "${var.prefix}-appliaction-insgiht"
  location = var.location
  application_type = var.application_type
  resource_group_name = var.resource_group_name
  workspace_id = azurerm_log_analytics_workspace.main_workspace.id
  
}
