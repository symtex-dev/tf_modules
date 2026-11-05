module "role_assignments" {
  source = "../../../core/role-assignment"

  assignments = {
    for name, assignment in var.assignments : name => merge(assignment, {
      role_definition_name = "AcrPull"
    })
  }
}
