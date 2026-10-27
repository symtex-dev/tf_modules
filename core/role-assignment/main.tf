resource "azurerm_role_assignment" "this" {
  for_each = var.assignments

  scope                            = each.value.scope
  principal_id                     = each.value.principal_id
  role_definition_name             = each.value.role_definition_name
  role_definition_id               = each.value.role_definition_id
  skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
}
