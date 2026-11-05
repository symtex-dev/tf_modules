output "id" {
  description = "Microsoft Entra security group object ID."
  value       = azuread_group.this.id
}

output "object_id" {
  description = "Microsoft Entra security group object ID, suitable for Azure role assignment principal_id."
  value       = azuread_group.this.object_id
}

output "display_name" {
  description = "Security group display name."
  value       = azuread_group.this.display_name
}
