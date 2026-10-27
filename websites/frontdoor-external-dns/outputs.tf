output "cdn_frontdoor_profile_id" {
  description = "The ID of the CDN Front Door profile."
  value       = azurerm_cdn_frontdoor_profile.main_profile.id
}

output "cdn_frontdoor_endpoint_id" {
  description = "The ID of the CDN Front Door endpoint."
  value       = azurerm_cdn_frontdoor_endpoint.main_endpoint.id
}

output "cdn_frontdoor_endpoint_hostname" {
  description = "The hostname of the Front Door endpoint. Point your external DNS CNAME records here."
  value       = azurerm_cdn_frontdoor_endpoint.main_endpoint.host_name
}

output "cdn_frontdoor_origin_group_id" {
  description = "The ID of the CDN Front Door origin group."
  value       = azurerm_cdn_frontdoor_origin_group.main_origin_group.id
}

output "cdn_frontdoor_origin_id" {
  description = "The ID of the CDN Front Door origin."
  value       = azurerm_cdn_frontdoor_origin.main_origin.id
}

output "cdn_frontdoor_custom_domain_id" {
  description = "The ID of the CDN Front Door custom domain."
  value       = azurerm_cdn_frontdoor_custom_domain.main_custom_domain.id
}

output "cdn_frontdoor_custom_domain_validation_token" {
  description = "The TXT validation token for the main custom domain. Add this as a TXT record in your external DNS provider."
  value       = azurerm_cdn_frontdoor_custom_domain.main_custom_domain.validation_token
}

output "cdn_frontdoor_route_id" {
  description = "The ID of the CDN Front Door route."
  value       = azurerm_cdn_frontdoor_route.main_route.id
}

output "cdn_frontdoor_firewall_policy_id" {
  description = "The ID of the CDN Front Door firewall policy."
  value       = azurerm_cdn_frontdoor_firewall_policy.main_firewall_policy.id
}

output "cdn_frontdoor_security_policy_id" {
  description = "The ID of the CDN Front Door security policy."
  value       = azurerm_cdn_frontdoor_security_policy.main_security_policy.id
}
