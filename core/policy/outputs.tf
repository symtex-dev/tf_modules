output "id" {
  description = "The resource ID of the policy definition."
  value       = azurerm_policy_definition.this.id
}

output "name" {
  description = "The name of the policy definition."
  value       = azurerm_policy_definition.this.name
}

output "policy_rule" {
  description = "The JSON policy rule stored by Azure."
  value       = azurerm_policy_definition.this.policy_rule
}
