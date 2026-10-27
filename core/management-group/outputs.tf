output "management_groups" {
  description = "Created management groups."

  value = {
    for name, group in azurerm_management_group.this :
    name => {
      id           = group.id
      name         = group.name
      display_name = group.display_name
    }
  }
}