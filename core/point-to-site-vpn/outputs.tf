output "vpn_gateway_id" {
  description = "Resource ID of the point-to-site VPN gateway."
  value       = azurerm_virtual_network_gateway.this.id
}

output "gateway_subnet_id" {
  description = "Resource ID of the GatewaySubnet created in the existing hub VNet."
  value       = module.gateway_subnet.id
}

output "public_ip_address" {
  description = "Public IP address clients use to reach the VPN gateway."
  value       = azurerm_public_ip.this.ip_address
}

output "client_address_pool" {
  description = "CIDR ranges assigned to connected VPN clients."
  value       = var.client_address_pool
}
