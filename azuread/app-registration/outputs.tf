output "id" {
  description = "Application resource ID."
  value       = azuread_application.this.id
}

output "object_id" {
  description = "Application object ID, distinct from the service principal object ID."
  value       = azuread_application.this.object_id
}

output "client_id" {
  description = "Application client ID for ARM_CLIENT_ID or AZURE_CLIENT_ID."
  value       = azuread_application.this.client_id
}

output "tenant_id" {
  description = "Microsoft Entra tenant ID for ARM_TENANT_ID or AZURE_TENANT_ID."
  value       = data.azuread_client_config.current.tenant_id
}

output "service_principal_object_id" {
  description = "Service principal object ID to use as principal_id in Azure role assignments."
  value       = azuread_service_principal.this.object_id
}

output "federated_credential_ids" {
  description = "Federated identity credential resource IDs keyed by display name."
  value       = { for name, credential in azuread_application_federated_identity_credential.this : name => credential.id }
}