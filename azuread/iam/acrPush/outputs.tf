output "ids" {
  description = "Storage Blob Data Contributor role assignment IDs keyed by caller-chosen names."
  value       = module.role_assignments.ids
}
