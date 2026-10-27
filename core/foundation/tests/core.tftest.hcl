mock_provider "azurerm" {
  mock_resource "azurerm_resource_group" {
    defaults = {
      id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/platform-rg"
    }
  }

  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/platform-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/platform-identity"
      principal_id = "12345678-1234-1234-1234-123456789012"
      client_id    = "22345678-1234-1234-1234-123456789012"
      tenant_id    = "32345678-1234-1234-1234-123456789012"
    }
  }

  mock_resource "azurerm_log_analytics_workspace" {
    defaults = {
      id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/platform-rg/providers/Microsoft.OperationalInsights/workspaces/platform-logs"
    }
  }

  mock_resource "azurerm_storage_account" {
    defaults = {
      id                    = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/platform-rg/providers/Microsoft.Storage/storageAccounts/platformtest123"
      primary_blob_endpoint = "https://platformtest123.blob.core.windows.net/"
    }
  }

  mock_resource "azurerm_private_dns_zone" {
    defaults = {
      id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/platform-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
    }
  }
}

variables {
  name                = "platform"
  resource_group_name = "platform-rg"
  location            = "westeurope"
  tags                = { environment = "test" }
}

run "foundation_without_storage" {
  command = apply

  assert {
    condition = (
      output.resource_group.name == "platform-rg" &&
      output.resource_group.location == "westeurope" &&
      output.identity.principal_id == "12345678-1234-1234-1234-123456789012" &&
      output.identity.client_id == "22345678-1234-1234-1234-123456789012" &&
      output.workspace_id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/platform-rg/providers/Microsoft.OperationalInsights/workspaces/platform-logs"
    )
    error_message = "The foundation must expose its composed resource group, identity, and workspace."
  }

  assert {
    condition     = output.storage == null && output.storage_private_endpoint == null && length(output.role_assignment_ids) == 0
    error_message = "Storage, private networking, and storage RBAC must be absent by default."
  }
}

run "foundation_with_storage" {
  command = apply

  variables {
    storage = {
      name                          = "platformtest123"
      public_network_access_enabled = true
    }
  }

  assert {
    condition = (
      output.storage.name == "platformtest123" &&
      output.storage.primary_blob_endpoint == "https://platformtest123.blob.core.windows.net/" &&
      length(output.role_assignment_ids) == 1 &&
      contains(keys(output.role_assignment_ids), "storage_blob") &&
      output.storage_private_endpoint == null
    )
    error_message = "Optional storage must expose blob details and grant the identity a scoped role, without implicit endpoints."
  }
}

run "foundation_with_private_storage" {
  command = apply

  variables {
    storage = {
      name = "platformtest123"
      private_endpoint = {
        subnet_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/spoke/subnets/private-endpoints"
        virtual_network_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/spoke"
      }
    }
  }

  assert {
    condition = (
      output.storage_private_endpoint != null &&
      output.storage_private_endpoint.dns_zone_id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/platform-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net" &&
      length(output.role_assignment_ids) == 1
    )
    error_message = "Private storage must compose DNS, an endpoint, and the identity role."
  }
}

run "storage_secure_defaults" {
  command = plan

  module {
    source = "../storage-account"
  }

  variables {
    name = "platformtest123"
  }

  assert {
    condition = (
      !azurerm_storage_account.this.public_network_access_enabled &&
      !azurerm_storage_account.this.shared_access_key_enabled &&
      !azurerm_storage_account.this.allow_nested_items_to_be_public &&
      azurerm_storage_account.this.https_traffic_only_enabled &&
      azurerm_storage_account.this.default_to_oauth_authentication &&
      azurerm_storage_account.this.min_tls_version == "TLS1_2" &&
      azurerm_storage_account.this.account_replication_type == "LRS" &&
      azurerm_storage_account.this.tags["environment"] == "test"
    )
    error_message = "Storage defaults must enforce private, authenticated, TLS-protected access and propagate tags."
  }
}

run "reject_storage_name" {
  command = plan

  module {
    source = "../storage-account"
  }

  variables {
    name = "Not-valid!"
  }

  expect_failures = [var.name]
}

run "storage_explicit_access_options" {
  command = plan

  module {
    source = "../storage-account"
  }

  variables {
    name                          = "platformtest123"
    replication_type              = "ZRS"
    public_network_access_enabled = true
    shared_access_key_enabled     = true
  }

  assert {
    condition = (
      azurerm_storage_account.this.public_network_access_enabled &&
      azurerm_storage_account.this.shared_access_key_enabled &&
      azurerm_storage_account.this.account_replication_type == "ZRS" &&
      !azurerm_storage_account.this.allow_nested_items_to_be_public
    )
    error_message = "Explicit access/replication options must be forwarded without allowing anonymous blobs."
  }
}

run "reject_replication_type" {
  command = plan

  module {
    source = "../storage-account"
  }

  variables {
    name             = "platformtest123"
    replication_type = "invalid"
  }

  expect_failures = [var.replication_type]
}

run "monitoring_workspace_connection" {
  command = apply

  module {
    source = "../monitoring"
  }

  variables {
    workspace_name            = "platform-logs"
    application_insights_name = "platform-insights"
    retention_in_days         = 90
  }

  assert {
    condition = (
      azurerm_application_insights.this.workspace_id == output.workspace_id &&
      azurerm_log_analytics_workspace.this.retention_in_days == 90 &&
      azurerm_application_insights.this.tags["environment"] == "test" &&
      azurerm_log_analytics_workspace.this.tags["environment"] == "test"
    )
    error_message = "Application Insights must use the created workspace, configured retention, and shared tags."
  }
}

run "reject_short_retention" {
  command = plan

  module {
    source = "../monitoring"
  }

  variables {
    workspace_name            = "platform-logs"
    application_insights_name = "platform-insights"
    retention_in_days         = 29
  }

  expect_failures = [var.retention_in_days]
}

run "monitoring_retention_boundaries" {
  command = plan

  module {
    source = "../monitoring"
  }

  variables {
    workspace_name            = "platform-logs"
    application_insights_name = "platform-insights"
    retention_in_days         = 730
  }

  assert {
    condition     = azurerm_log_analytics_workspace.this.retention_in_days == 730
    error_message = "The maximum supported retention of 730 days must be accepted."
  }
}

run "reject_long_retention" {
  command = plan

  module {
    source = "../monitoring"
  }

  variables {
    workspace_name            = "platform-logs"
    application_insights_name = "platform-insights"
    retention_in_days         = 731
  }

  expect_failures = [var.retention_in_days]
}

run "reject_fractional_retention" {
  command = plan

  module {
    source = "../monitoring"
  }

  variables {
    workspace_name            = "platform-logs"
    application_insights_name = "platform-insights"
    retention_in_days         = 30.5
  }

  expect_failures = [var.retention_in_days]
}

run "roles_by_name_and_id" {
  command = plan

  module {
    source = "../role-assignment"
  }

  variables {
    assignments = {
      reader = {
        scope                = "/subscriptions/12345678-1234-1234-1234-123456789012"
        principal_id         = "12345678-1234-1234-1234-123456789012"
        role_definition_name = "Reader"
      }
      custom = {
        scope                            = "/subscriptions/12345678-1234-1234-1234-123456789012"
        principal_id                     = "12345678-1234-1234-1234-123456789012"
        role_definition_id               = "/subscriptions/12345678-1234-1234-1234-123456789012/providers/Microsoft.Authorization/roleDefinitions/22345678-1234-1234-1234-123456789012"
        skip_service_principal_aad_check = true
      }
    }
  }

  assert {
    condition = (
      length(azurerm_role_assignment.this) == 2 &&
      azurerm_role_assignment.this["reader"].role_definition_name == "Reader" &&
      !azurerm_role_assignment.this["reader"].skip_service_principal_aad_check &&
      azurerm_role_assignment.this["custom"].skip_service_principal_aad_check
    )
    error_message = "Role assignments must support stable keys, role names/IDs, and explicit service principal checks."
  }
}

run "reject_missing_role" {
  command = plan

  module {
    source = "../role-assignment"
  }

  variables {
    assignments = {
      invalid = {
        scope        = "/subscriptions/12345678-1234-1234-1234-123456789012"
        principal_id = "12345678-1234-1234-1234-123456789012"
      }
    }
  }

  expect_failures = [var.assignments]
}

run "reject_both_roles" {
  command = plan

  module {
    source = "../role-assignment"
  }

  variables {
    assignments = {
      invalid = {
        scope                = "/subscriptions/12345678-1234-1234-1234-123456789012"
        principal_id         = "12345678-1234-1234-1234-123456789012"
        role_definition_name = "Reader"
        role_definition_id   = "/subscriptions/12345678-1234-1234-1234-123456789012/providers/Microsoft.Authorization/roleDefinitions/22345678-1234-1234-1234-123456789012"
      }
    }
  }

  expect_failures = [var.assignments]
}

run "reject_empty_role_scope" {
  command = plan

  module {
    source = "../role-assignment"
  }

  variables {
    assignments = {
      invalid = {
        scope                = " "
        principal_id         = "12345678-1234-1234-1234-123456789012"
        role_definition_name = "Reader"
      }
    }
  }

  expect_failures = [var.assignments]
}

run "private_dns_links" {
  command = plan

  module {
    source = "../private-dns-zone"
  }

  variables {
    name = "privatelink.blob.core.windows.net"
    virtual_network_links = {
      spoke = {
        virtual_network_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/spoke"
      }
    }
  }

  assert {
    condition = (
      length(azurerm_private_dns_zone_virtual_network_link.this) == 1 &&
      !azurerm_private_dns_zone_virtual_network_link.this["spoke"].registration_enabled &&
      azurerm_private_dns_zone_virtual_network_link.this["spoke"].private_dns_zone_name == "privatelink.blob.core.windows.net" &&
      azurerm_private_dns_zone_virtual_network_link.this["spoke"].tags["environment"] == "test"
    )
    error_message = "VNet links must target the zone with auto-registration disabled and tags propagated."
  }
}

run "private_endpoint_without_dns" {
  command = plan

  module {
    source = "../private-endpoint"
  }

  variables {
    subnet_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/spoke/subnets/private-endpoints"
    private_connection_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/platform-rg/providers/Microsoft.Storage/storageAccounts/platformtest123"
    subresource_names              = ["blob"]
  }

  assert {
    condition = (
      length(azurerm_private_endpoint.this.private_dns_zone_group) == 0 &&
      !azurerm_private_endpoint.this.private_service_connection[0].is_manual_connection &&
      azurerm_private_endpoint.this.private_service_connection[0].subresource_names == tolist(["blob"])
    )
    error_message = "Standalone endpoints must support external DNS and automatic approval by default."
  }
}

run "private_dns_without_links" {
  command = plan

  module {
    source = "../private-dns-zone"
  }

  variables {
    name = "privatelink.blob.core.windows.net"
  }

  assert {
    condition     = length(azurerm_private_dns_zone_virtual_network_link.this) == 0
    error_message = "A standalone zone must not implicitly link networks."
  }
}

run "private_endpoint_manual_with_dns" {
  command = plan

  module {
    source = "../private-endpoint"
  }

  variables {
    subnet_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/spoke/subnets/private-endpoints"
    private_connection_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/platform-rg/providers/Microsoft.Storage/storageAccounts/platformtest123"
    subresource_names              = ["blob"]
    private_dns_zone_ids           = ["/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/platform-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"]
    is_manual_connection           = true
    request_message                = "Please approve platform storage access."
  }

  assert {
    condition = (
      length(azurerm_private_endpoint.this.private_dns_zone_group) == 1 &&
      azurerm_private_endpoint.this.private_dns_zone_group[0].private_dns_zone_ids == var.private_dns_zone_ids &&
      azurerm_private_endpoint.this.private_service_connection[0].is_manual_connection &&
      azurerm_private_endpoint.this.private_service_connection[0].request_message == var.request_message &&
      azurerm_private_endpoint.this.private_service_connection[0].private_connection_resource_id == var.private_connection_resource_id &&
      azurerm_private_endpoint.this.subnet_id == var.subnet_id
    )
    error_message = "Manual connections must forward the target, subnet, request message, and DNS zone IDs."
  }
}

run "reject_empty_subresources" {
  command = plan

  module {
    source = "../private-endpoint"
  }

  variables {
    subnet_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/spoke/subnets/private-endpoints"
    private_connection_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/platform-rg/providers/Microsoft.Storage/storageAccounts/platformtest123"
    subresource_names              = []
  }

  expect_failures = [var.subresource_names]
}
