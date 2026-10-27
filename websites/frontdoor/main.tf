############################################################
# Resource: azurerm_cdn_frontdoor_profile.main_profile
############################################################
resource "azurerm_cdn_frontdoor_profile" "main_profile" {
  name                = var.main_profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.main_profile_sku
}

############################################################
# Resource: azurerm_cdn_frontdoor_endpoint.main_endpoint
############################################################
resource "azurerm_cdn_frontdoor_endpoint" "main_endpoint" {
  name                     = var.main_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main_profile.id
}

############################################################
# Resource: azurerm_cdn_frontdoor_origin_group.main_origin_group
############################################################
resource "azurerm_cdn_frontdoor_origin_group" "main_origin_group" {
  name                     = var.main_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main_profile.id

  load_balancing {}
}

############################################################
# Resource: azurerm_cdn_frontdoor_origin.main_origin
############################################################
resource "azurerm_cdn_frontdoor_origin" "main_origin" {

  depends_on = [ azurerm_cdn_frontdoor_origin_group.main_origin_group ]

  name                           = var.main_origin_name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.main_origin_group.id
  host_name                      = var.main_origin_host_name
  certificate_name_check_enabled = var.certificate_name_check_enabled
  origin_host_header             = var.main_origin_host_name

  enabled = true

  http_port  = 80
  https_port = 443
 
  priority = 1
  weight   = 1000

}

############################################################
# Resource: azurerm_cdn_frontdoor_custom_domain.main_custom_domain
############################################################
resource "azurerm_cdn_frontdoor_custom_domain" "main_custom_domain" {
  name                     = var.main_custom_domain_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main_profile.id
  dns_zone_id              = var.dns_zone_id
  host_name                = var.fd_dns_zone_name
  tls { 
    certificate_type = var.certificate_type
  }
}

############################################################
# Resource: azurerm_cdn_frontdoor_custom_domain.additional_domains
############################################################
resource "azurerm_cdn_frontdoor_custom_domain" "additional_domains" {
  for_each = { for d in var.additional_custom_domains : d.name => d }

  name                      = each.value.name
  cdn_frontdoor_profile_id  = azurerm_cdn_frontdoor_profile.main_profile.id
  dns_zone_id               = var.dns_zone_id
  host_name                 = each.value.host_name

  tls {
    certificate_type = var.certificate_type
  }
}

############################################################
# Resource: azurerm_cdn_frontdoor_route.main_route
############################################################
resource "azurerm_cdn_frontdoor_route" "main_route" {

  name                          = var.main_route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main_origin_group.id

  cdn_frontdoor_origin_ids = [
    azurerm_cdn_frontdoor_origin.main_origin.id
  ]

  cdn_frontdoor_custom_domain_ids = concat(
    [azurerm_cdn_frontdoor_custom_domain.main_custom_domain.id],
    [for d in azurerm_cdn_frontdoor_custom_domain.additional_domains : d.id]
  )

  patterns_to_match   = ["/*"]
  supported_protocols = ["Http", "Https"]
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  link_to_default_domain = true

}

############################################################
# Resource: azurerm_cdn_frontdoor_firewall_policy.main_firewall_policy
############################################################
resource "azurerm_cdn_frontdoor_firewall_policy" "main_firewall_policy" {
  name                = var.main_firewall_policy_name
  resource_group_name = var.resource_group_name
  sku_name            = azurerm_cdn_frontdoor_profile.main_profile.sku_name
  mode                = var.firewall_policy_mode
}

############################################################
# Resource: azurerm_cdn_frontdoor_security_policy.main_security_policy
############################################################
resource "azurerm_cdn_frontdoor_security_policy" "main_security_policy" {
  name                     = var.main_security_policy_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main_profile.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.main_firewall_policy.id

      association {
        dynamic "domain" {
          for_each = concat(
            [azurerm_cdn_frontdoor_custom_domain.main_custom_domain.id],
            [for d in azurerm_cdn_frontdoor_custom_domain.additional_domains : d.id]
          )
          content {
            cdn_frontdoor_domain_id = domain.value
          }
        }

        patterns_to_match = var.patterns_to_match
      }
    }
  }
}

############################################################
# Resource: azurerm_dns_cname_record.subdomain
############################################################
resource "azurerm_dns_cname_record" "subdomain" {
  for_each = { for r in var.additional_custom_domains : r.name => r }
  name                = each.value.subdomain
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_resource_group_name
  ttl                 = 300
  record              = azurerm_cdn_frontdoor_endpoint.main_endpoint.host_name
}

# Dev: creates e.g. "dev" CNAME → Front Door endpoint in the shared zone
resource "azurerm_dns_cname_record" "apex_cname" {
  count               = var.apex_cname_name != null ? 1 : 0
  name                = var.apex_cname_name
  zone_name           = var.dns_zone_name
  resource_group_name = var.dns_resource_group_name
  ttl                 = 300
  record              = azurerm_cdn_frontdoor_endpoint.main_endpoint.host_name
}

# Prod: creates alias A record "@" → Front Door profile (required for apex domains)
resource "azurerm_dns_a_record" "apex_alias" {
  count              = var.create_apex_alias ? 1 : 0
  name               = "@"
  zone_name          = var.dns_zone_name
  resource_group_name = var.dns_resource_group_name
  ttl                = 300
  target_resource_id = azurerm_cdn_frontdoor_endpoint.main_endpoint.id  # endpoint, not profile
}


############################################################
# Resource: azurerm_monitor_diagnostic_setting.frontdoor_monitor
############################################################
resource "azurerm_monitor_diagnostic_setting" "frontdoor_monitor" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.prefix}-monitor-settings"
  target_resource_id         = azurerm_cdn_frontdoor_profile.main_profile.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "FrontdoorAccessLog"
  }

  enabled_log {
    category = "FrontdoorWebApplicationFirewallLog"
  }

  metric {
    category = "AllMetrics"
  }
}

