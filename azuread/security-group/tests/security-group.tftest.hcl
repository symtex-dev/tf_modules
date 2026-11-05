mock_provider "azuread" {
  mock_data "azuread_client_config" {
    defaults = {
      object_id = "11111111-1111-1111-1111-111111111111"
      tenant_id = "22222222-2222-2222-2222-222222222222"
    }
  }

  mock_resource "azuread_group" {
    defaults = {
      id        = "33333333-3333-3333-3333-333333333333"
      object_id = "33333333-3333-3333-3333-333333333333"
    }
  }
}

variables {
  name        = "acr-developers"
  description = "Developers who can push and pull container images"
  owners      = ["44444444-4444-4444-4444-444444444444"]
  members     = ["55555555-5555-5555-5555-555555555555"]
}

run "create_security_group" {
  command = plan

  assert {
    condition = (
      azuread_group.this.display_name == "acr-developers" &&
      azuread_group.this.description == "Developers who can push and pull container images" &&
      azuread_group.this.security_enabled &&
      !azuread_group.this.mail_enabled
    )
    error_message = "The module must create a security-enabled, mail-disabled group with the requested name and description."
  }

  assert {
    condition = (
      contains(azuread_group.this.owners, "11111111-1111-1111-1111-111111111111") &&
      contains(azuread_group.this.owners, "44444444-4444-4444-4444-444444444444") &&
      azuread_group.this.members == toset(["55555555-5555-5555-5555-555555555555"])
    )
    error_message = "The group must include the executing identity and additional owners, and manage the requested members."
  }
}

run "empty_members_and_additional_owners" {
  command = plan

  variables {
    name    = "empty-security-group"
    owners  = []
    members = []
  }

  assert {
    condition = (
      length(azuread_group.this.members) == 0 &&
      azuread_group.this.owners == toset(["11111111-1111-1111-1111-111111111111"])
    )
    error_message = "The group must default to no members and retain the executing identity as its owner."
  }
}

run "reject_blank_name" {
  command = plan

  variables {
    name = "  "
  }

  expect_failures = [var.name]
}
