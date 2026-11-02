output "ids" {
  description = "Storage Blob Data Owner role assignment IDs keyed by caller-chosen names."
  value       = module.role_assignments.ids
}
