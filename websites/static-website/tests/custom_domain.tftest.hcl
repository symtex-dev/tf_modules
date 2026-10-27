mock_provider "azurerm" {
  mock_resource "azurerm_static_web_app" {
    defaults = {
      id                = "/subscriptions/12345678-1234-9876-4563-123456789012/resourceGroups/website-rg/providers/Microsoft.Web/staticSites/smtx-test"
      default_host_name = "example.azurestaticapps.net"
    }
  }
}

variables {
  prefix              = "test"
  resource_group_name = "website-rg"
  location            = "westeurope"
  sku_size            = "Free"
  tags = {
    environment = "test"
  }
}

run "without_custom_domain" {
  command = plan

  assert {
    condition     = length(azurerm_dns_cname_record.this) == 0 && length(azurerm_static_web_app_custom_domain.this) == 0
    error_message = "Custom domain resources must not be created by default."
  }

  assert {
    condition     = output.custom_domain_name == null && azurerm_static_web_app.this.name == "smtx-test"
    error_message = "Existing app naming and the default disabled state must be preserved."
  }
}

run "create_dns_zone" {
  command = apply

  module {
    source = "../dns_zone"
  }

  variables {
    dns_zone_name       = "domain.com"
    resource_group_name = "dns-rg"
  }

  assert {
    condition     = output.dns_zone_name == "domain.com" && output.resource_group_name == "dns-rg"
    error_message = "The DNS module must expose the zone name and resource group for downstream dependencies."
  }
}

run "with_custom_domain" {
  command = apply

  variables {
    custom_domain = {
      subdomain           = "dev"
      zone_name           = run.create_dns_zone.dns_zone_name
      resource_group_name = run.create_dns_zone.resource_group_name
    }
  }

  assert {
    condition = (
      length(azurerm_dns_cname_record.this) == 1 &&
      length(azurerm_static_web_app_custom_domain.this) == 1 &&
      azurerm_dns_cname_record.this[0].name == "dev" &&
      azurerm_dns_cname_record.this[0].zone_name == "domain.com" &&
      azurerm_dns_cname_record.this[0].resource_group_name == "dns-rg" &&
      azurerm_dns_cname_record.this[0].ttl == 300 &&
      azurerm_dns_cname_record.this[0].tags["environment"] == "test"
    )
    error_message = "The CNAME must be created in the specified DNS zone and resource group with the expected TTL and tags."
  }

  assert {
    condition = (
      azurerm_dns_cname_record.this[0].record == output.default_host_name &&
      output.default_host_name == "example.azurestaticapps.net" &&
      azurerm_static_web_app_custom_domain.this[0].static_web_app_id == output.id &&
      azurerm_static_web_app_custom_domain.this[0].validation_type == "cname-delegation" &&
      output.custom_domain_name == "dev.domain.com"
    )
    error_message = "The custom domain must point to and be registered with this app using CNAME validation."
  }
}

run "reject_apex_domain" {
  command = plan

  variables {
    custom_domain = {
      subdomain           = "@"
      zone_name           = "domain.com"
      resource_group_name = "dns-rg"
    }
  }

  expect_failures = [var.custom_domain]
}

run "reject_empty_dns_resource_group" {
  command = plan

  variables {
    custom_domain = {
      subdomain           = "dev"
      zone_name           = "domain.com"
      resource_group_name = ""
    }
  }

  expect_failures = [var.custom_domain]
}
