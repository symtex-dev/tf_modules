variable "assignments" {
  description = "Role assignments keyed by stable caller-chosen names, not computed resource IDs. Set exactly one role definition name or ID."
  type = map(object({
    scope                            = string
    principal_id                     = string
    role_definition_name             = optional(string)
    role_definition_id               = optional(string)
    skip_service_principal_aad_check = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for assignment in values(var.assignments) :
      (assignment.role_definition_name != null) != (assignment.role_definition_id != null)
    ])
    error_message = "Each assignment must set exactly one of role_definition_name and role_definition_id."
  }

  validation {
    condition = alltrue([
      for assignment in values(var.assignments) :
      alltrue([
        for value in [assignment.scope, assignment.principal_id, assignment.role_definition_name, assignment.role_definition_id] :
        value == null ? true : trimspace(value) != ""
      ])
    ])
    error_message = "Scope, principal ID, and supplied role definitions must not be empty."
  }
}
