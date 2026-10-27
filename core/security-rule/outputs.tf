output "ids" {
  value = { for name, rule in azurerm_network_security_rule.this : name => rule.id }
}