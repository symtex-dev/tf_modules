output "resource_group" {
  description = "Created resource group."
  value = {
    id       = module.resource_group.id
    name     = module.resource_group.name
    location = module.resource_group.location
  }
}

output "identity" {
  description = "User-assigned identity for attachment to workloads and Microsoft Entra authentication."
  value = {
    id           = module.identity.id
    client_id    = module.identity.client_id
    principal_id = module.identity.principal_id
    tenant_id    = module.identity.tenant_id
  }
}

output "workspace_id" {
  description = "Log Analytics workspace resource ID."
  value       = module.monitoring.workspace_id
}

output "application_insights_id" {
  description = "Application Insights resource ID."
  value       = module.monitoring.application_insights_id
}

output "application_insights_connection_string" {
  description = "Application telemetry connection string."
  value       = module.monitoring.connection_string
  sensitive   = true
}

output "storage" {
  description = "Optional storage details, or null when disabled."
  value = var.storage == null ? null : {
    id                    = module.storage["main"].id
    name                  = module.storage["main"].name
    primary_blob_endpoint = module.storage["main"].primary_blob_endpoint
  }
}

output "role_assignment_ids" {
  description = "Storage role assignment IDs for the foundation identity."
  value       = module.roles.ids
}

output "storage_private_endpoint" {
  description = "Optional blob private endpoint details."
  value = var.storage == null ? null : (var.storage.private_endpoint == null ? null : {
    id                 = module.storage_endpoint["main"].id
    private_ip_address = module.storage_endpoint["main"].private_ip_address
    dns_zone_id        = module.storage_dns["main"].id
  })
}
