data "azuread_client_config" "current" {}

locals {
  owners = setunion(var.owners, toset([data.azuread_client_config.current.object_id]))
}

resource "azuread_group" "this" {
  display_name     = var.name
  description      = var.description
  security_enabled = true
  mail_enabled     = false
  owners           = local.owners
  members          = var.members
}
