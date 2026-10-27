resource "azurerm_dns_zone" "this" {
  for_each = var.domains

  name                = each.key
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags
}

locals {
  a_records = {
    for record in flatten([
      for domain, zone in var.domains : [
        for name, config in zone.record_sets.a : {
          domain = domain
          name   = name
          config = config
        }
      ]
    ]) : "${record.domain}/${record.name}" => record
  }

  aaaa_records = {
    for record in flatten([
      for domain, zone in var.domains : [
        for name, config in zone.record_sets.aaaa : {
          domain = domain
          name   = name
          config = config
        }
      ]
    ]) : "${record.domain}/${record.name}" => record
  }

  cname_records = {
    for record in flatten([
      for domain, zone in var.domains : [
        for name, config in zone.record_sets.cname : {
          domain = domain
          name   = name
          config = config
        }
      ]
    ]) : "${record.domain}/${record.name}" => record
  }

  mx_records = {
    for record in flatten([
      for domain, zone in var.domains : [
        for name, config in zone.record_sets.mx : {
          domain = domain
          name   = name
          config = config
        }
      ]
    ]) : "${record.domain}/${record.name}" => record
  }

  txt_records = {
    for record in flatten([
      for domain, zone in var.domains : [
        for name, config in zone.record_sets.txt : {
          domain = domain
          name   = name
          config = config
        }
      ]
    ]) : "${record.domain}/${record.name}" => record
  }

  srv_records = {
    for record in flatten([
      for domain, zone in var.domains : [
        for name, config in zone.record_sets.srv : {
          domain = domain
          name   = name
          config = config
        }
      ]
    ]) : "${record.domain}/${record.name}" => record
  }
}

resource "azurerm_dns_a_record" "this" {
  for_each = local.a_records

  depends_on = [azurerm_dns_zone.this]

  name                = each.value.name
  zone_name           = each.value.domain
  resource_group_name = var.domains[each.value.domain].resource_group_name
  ttl                 = each.value.config.ttl
  records             = each.value.config.records
  tags                = var.domains[each.value.domain].tags
}

resource "azurerm_dns_aaaa_record" "this" {
  for_each = local.aaaa_records

  depends_on = [azurerm_dns_zone.this]

  name                = each.value.name
  zone_name           = each.value.domain
  resource_group_name = var.domains[each.value.domain].resource_group_name
  ttl                 = each.value.config.ttl
  records             = each.value.config.records
  tags                = var.domains[each.value.domain].tags
}

resource "azurerm_dns_cname_record" "this" {
  for_each = local.cname_records

  depends_on = [azurerm_dns_zone.this]

  name                = each.value.name
  zone_name           = each.value.domain
  resource_group_name = var.domains[each.value.domain].resource_group_name
  ttl                 = each.value.config.ttl
  record              = each.value.config.target
  tags                = var.domains[each.value.domain].tags
}

resource "azurerm_dns_mx_record" "this" {
  for_each = local.mx_records

  depends_on = [azurerm_dns_zone.this]

  name                = each.value.name
  zone_name           = each.value.domain
  resource_group_name = var.domains[each.value.domain].resource_group_name
  ttl                 = each.value.config.ttl
  tags                = var.domains[each.value.domain].tags

  dynamic "record" {
    for_each = each.value.config.records
    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }
}

resource "azurerm_dns_txt_record" "this" {
  for_each = local.txt_records

  depends_on = [azurerm_dns_zone.this]

  name                = each.value.name
  zone_name           = each.value.domain
  resource_group_name = var.domains[each.value.domain].resource_group_name
  ttl                 = each.value.config.ttl
  tags                = var.domains[each.value.domain].tags

  dynamic "record" {
    for_each = each.value.config.records
    content {
      value = record.value
    }
  }
}

resource "azurerm_dns_srv_record" "this" {
  for_each = local.srv_records

  depends_on = [azurerm_dns_zone.this]

  name                = each.value.name
  zone_name           = each.value.domain
  resource_group_name = var.domains[each.value.domain].resource_group_name
  ttl                 = each.value.config.ttl
  tags                = var.domains[each.value.domain].tags

  dynamic "record" {
    for_each = each.value.config.records
    content {
      priority = record.value.priority
      weight   = record.value.weight
      port     = record.value.port
      target   = record.value.target
    }
  }
}