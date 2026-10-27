mock_provider "azuread" {
  mock_data "azuread_client_config" {
    defaults = {
      object_id = "11111111-1111-1111-1111-111111111111"
      tenant_id = "22222222-2222-2222-2222-222222222222"
    }
  }
}

variables {
  name   = "landing-zone-ci"
  owners = ["33333333-3333-3333-3333-333333333333"]

  federated_credentials = {
    github-plan = {
      issuer  = "https://token.actions.githubusercontent.com"
      subject = "repo:example/landing-zone:environment:azure-plan"
    }
    github-apply = {
      issuer    = "https://token.actions.githubusercontent.com"
      subject   = "repo:example/landing-zone:environment:azure-apply"
      audiences = ["api://AzureADTokenExchange"]
    }
  }
}

run "plan_oidc_registration" {
  command = plan

  assert {
    condition     = azuread_application.this.sign_in_audience == "AzureADMyOrg" && length(azuread_application.this.password) == 0
    error_message = "The application must be single-tenant without a client secret."
  }

  assert {
    condition = (
      contains(azuread_application.this.owners, "11111111-1111-1111-1111-111111111111") &&
      contains(azuread_application.this.owners, "33333333-3333-3333-3333-333333333333") &&
      azuread_service_principal.this.owners == azuread_application.this.owners
    )
    error_message = "Both resources must include the executing principal and additional owners."
  }

  assert {
    condition = (
      length(azuread_application_federated_identity_credential.this) == 2 &&
      one(azuread_application_federated_identity_credential.this["github-plan"].audiences) == "api://AzureADTokenExchange" &&
      azuread_application_federated_identity_credential.this["github-apply"].subject == "repo:example/landing-zone:environment:azure-apply"
    )
    error_message = "Credentials must preserve their subjects and default the Azure token exchange audience."
  }
}

run "reject_duplicate_trusts" {
  command = plan

  variables {
    federated_credentials = {
      first = {
        issuer  = "https://token.actions.githubusercontent.com"
        subject = "repo:example/landing-zone:ref:refs/heads/main"
      }
      second = {
        issuer  = "https://token.actions.githubusercontent.com"
        subject = "repo:example/landing-zone:ref:refs/heads/main"
      }
    }
  }

  expect_failures = [var.federated_credentials]
}

run "reject_empty_credentials" {
  command = plan

  variables {
    federated_credentials = {}
  }

  expect_failures = [var.federated_credentials]
}