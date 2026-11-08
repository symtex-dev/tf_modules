output "id" {
  description = "Linux VM resource ID."
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "Linux VM name."
  value       = azurerm_linux_virtual_machine.this.name
}

output "network_interface_id" {
  description = "Network interface resource ID."
  value       = azurerm_network_interface.this.id
}

output "private_ip_address" {
  description = "Private IP address assigned to the VM NIC."
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  description = "Optional public IP address, or null when disabled."
  value       = var.public_ip == null ? null : azurerm_public_ip.this["main"].ip_address
}
