output "id" {
  description = "Private DNS zone resource ID."
  value       = azurerm_private_dns_zone.this.id
}

output "name" {
  description = "Private DNS zone name."
  value       = azurerm_private_dns_zone.this.name
}

output "virtual_network_link_ids" {
  description = "VNet link IDs keyed by link name."
  value       = { for name, link in azurerm_private_dns_zone_virtual_network_link.this : name => link.id }
}
