resource "azurerm_cdn_frontdoor_profile" "main_profile" {
  name                = var.main_profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.main_profile_sku
}

resource "azurerm_cdn_frontdoor_endpoint" "main_endpoint" {
  name                     = var.main_endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main_profile.id
}

resource "azurerm_cdn_frontdoor_origin_group" "main_origin_group" {
  name                     = var.main_origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main_profile.id

  load_balancing {}
}

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

resource "azurerm_cdn_frontdoor_custom_domain" "main_custom_domain" {
  name                     = var.main_custom_domain_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main_profile.id
  host_name                = var.fd_dns_zone_name
  tls {
    certificate_type = var.certificate_type
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "additional_domains" {
  for_each = { for d in var.additional_custom_domains : d.name => d }

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main_profile.id
  host_name                = each.value.host_name

  tls {
    certificate_type = var.certificate_type
  }
}

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

  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  link_to_default_domain = true

}

resource "azurerm_cdn_frontdoor_firewall_policy" "main_firewall_policy" {
  name                = var.main_firewall_policy_name
  resource_group_name = var.resource_group_name
  sku_name            = azurerm_cdn_frontdoor_profile.main_profile.sku_name
  mode                = var.firewall_policy_mode
}

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
