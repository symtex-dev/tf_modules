resource "azurerm_static_web_app" "this" {
  name                = "smtx-${var.prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku_size = var.sku_size
  tags     = var.tags
}

resource "azurerm_dns_cname_record" "this" {
  count = var.custom_domain == null ? 0 : 1

  name                = var.custom_domain.subdomain
  zone_name           = var.custom_domain.zone_name
  resource_group_name = var.custom_domain.resource_group_name
  ttl                 = 300
  record              = azurerm_static_web_app.this.default_host_name
  tags                = var.tags
}

resource "azurerm_static_web_app_custom_domain" "this" {
  count = var.custom_domain == null ? 0 : 1

  static_web_app_id = azurerm_static_web_app.this.id
  domain_name       = "${azurerm_dns_cname_record.this[0].name}.${azurerm_dns_cname_record.this[0].zone_name}"
  validation_type   = "cname-delegation"
}