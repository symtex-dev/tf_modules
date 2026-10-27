resource "azurerm_management_group" "this" {
  for_each = var.management_groups

  name         = each.key
  display_name = each.value.display_name

  parent_management_group_id = each.value.parent_id
}