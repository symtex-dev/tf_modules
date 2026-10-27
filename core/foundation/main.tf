module "resource_group" {
  source = "../resource-group"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "identity" {
  source = "../managed-identity"

  name                = "${var.name}-identity"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = var.tags
}

module "monitoring" {
  source = "../monitoring"

  workspace_name            = "${var.name}-logs"
  application_insights_name = "${var.name}-insights"
  resource_group_name       = module.resource_group.name
  location                  = module.resource_group.location
  retention_in_days         = var.log_retention_in_days
  tags                      = var.tags
}

module "storage" {
  source   = "../storage-account"
  for_each = var.storage == null ? {} : { main = var.storage }

  name                          = each.value.name
  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  replication_type              = each.value.replication_type
  public_network_access_enabled = each.value.public_network_access_enabled
  tags                          = var.tags
}

module "roles" {
  source = "../role-assignment"

  assignments = var.storage == null ? {} : {
    storage_blob = {
      scope                            = module.storage["main"].id
      principal_id                     = module.identity.principal_id
      role_definition_name             = "Storage Blob Data Contributor"
      skip_service_principal_aad_check = true
    }
  }
}

module "storage_dns" {
  source   = "../private-dns-zone"
  for_each = var.storage == null ? {} : (var.storage.private_endpoint == null ? {} : { main = var.storage.private_endpoint })

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.resource_group.name
  virtual_network_links = {
    storage = {
      virtual_network_id = each.value.virtual_network_id
    }
  }
  tags = var.tags
}

module "storage_endpoint" {
  source   = "../private-endpoint"
  for_each = var.storage == null ? {} : (var.storage.private_endpoint == null ? {} : { main = var.storage.private_endpoint })

  name                           = "${var.name}-blob-pe"
  resource_group_name            = module.resource_group.name
  location                       = module.resource_group.location
  subnet_id                      = each.value.subnet_id
  private_connection_resource_id = module.storage["main"].id
  subresource_names              = ["blob"]
  private_dns_zone_ids           = [module.storage_dns["main"].id]
  tags                           = var.tags
}
