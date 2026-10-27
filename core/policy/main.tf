resource "azurerm_policy_definition" "this" {
  name         = var.name
  display_name = var.display_name
  description  = var.description
  policy_type  = var.policy_type
  mode         = var.mode
  policy_rule  = jsonencode(var.policy_rule)
}
