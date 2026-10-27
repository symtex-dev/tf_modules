output "local_to_remote_peering_id" {
  value = try(azurerm_virtual_network_peering.local_to_remote["connection"].id, null)
}

output "remote_to_local_peering_id" {
  value = try(azurerm_virtual_network_peering.remote_to_local["connection"].id, null)
}

output "vpn_gateway_id" {
  value = try(azurerm_virtual_network_gateway.this["gateway"].id, null)
}

output "vpn_public_ip" {
  value = try(azurerm_public_ip.vpn["gateway"].ip_address, null)
}

output "vpn_connection_ids" {
  value = { for name, connection in azurerm_virtual_network_gateway_connection.this : name => connection.id }
}