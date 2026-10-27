output "id" {
  value = azurerm_route_table.this.id
}

output "name" {
  value = azurerm_route_table.this.name
}

output "route_ids" {
  value = { for name, route in azurerm_route.this : name => route.id }
}