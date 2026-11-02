output "ids" {
  description = "Owner role assignment IDs keyed by caller-chosen names."
  value       = module.role_assignments.ids
}
