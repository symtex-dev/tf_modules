data "azuread_client_config" "current" {}

locals {
  owners = setunion(var.owners, toset([data.azuread_client_config.current.object_id]))
}

resource "azuread_application" "this" {
  display_name            = var.name
  description             = var.description
  owners                  = local.owners
  sign_in_audience        = "AzureADMyOrg"
  prevent_duplicate_names = true
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
  owners    = local.owners
}

resource "azuread_application_federated_identity_credential" "this" {
  for_each = var.federated_credentials

  application_id = azuread_application.this.id
  display_name   = each.key
  description    = each.value.description
  audiences      = each.value.audiences
  issuer         = each.value.issuer
  subject        = each.value.subject
}