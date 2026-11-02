output "ids" {
  description = "Contributor role assignment IDs keyed by caller-chosen names."
  value       = module.role_assignments.ids
}
