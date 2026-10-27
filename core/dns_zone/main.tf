resource "azurerm_dns_zone" "main_dns_zone" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_txt_record" "main_txt" {
  count               = var.create_txt_record ? 1 : 0

  name                = var.txt_record_name
  zone_name           = azurerm_dns_zone.main_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = var.txt_record_ttl

  dynamic "record" {
    for_each = var.txt_record_values
    content {
      value = record.value
    }
  }

  tags = var.tags
}

resource "azurerm_dns_mx_record" "main_mx" {
  count               = var.create_mx_record ? 1 : 0

  name                = var.mx_record_name
  zone_name           = azurerm_dns_zone.main_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = var.mx_record_ttl

  dynamic "record" {
    for_each = var.mx_records
    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }

  tags = var.tags
}
