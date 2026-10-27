output "dns_zone_id" {
  description = "The ID of the DNS zone."
  value       = azurerm_dns_zone.main_dns_zone.id
}

output "dns_zone_name" {
  description = "The name of the DNS zone."
  value       = azurerm_dns_zone.main_dns_zone.name
}

output "resource_group_name" {
  description = "The resource group containing the DNS zone."
  value       = azurerm_dns_zone.main_dns_zone.resource_group_name
}

output "name_servers" {
  description = "Azure DNS nameservers to configure at the domain registrar."
  value       = azurerm_dns_zone.main_dns_zone.name_servers
}

output "txt_record_id" {
  description = "The ID of the TXT record, if created."
  value       = var.create_txt_record ? azurerm_dns_txt_record.main_txt[0].id : null
}

output "mx_record_id" {
  description = "The ID of the MX record, if created."
  value       = var.create_mx_record ? azurerm_dns_mx_record.main_mx[0].id : null
}
