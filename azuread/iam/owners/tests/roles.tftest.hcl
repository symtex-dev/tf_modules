mock_provider "azurerm" {
  mock_resource "azurerm_role_assignment" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleAssignments/22222222-2222-2222-2222-222222222222"
    }
  }
}

variables {
  assignments = {
    group = {
      scope        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example"
      principal_id = "11111111-1111-1111-1111-111111111111"
    }
    workload = {
      scope                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.Storage/storageAccounts/example/blobServices/default/containers/data"
      principal_id                     = "33333333-3333-3333-3333-333333333333"
      skip_service_principal_aad_check = true
    }
  }
}

run "owners" {
  command = apply

  assert {
    condition = output.ids == {
      group    = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleAssignments/22222222-2222-2222-2222-222222222222"
      workload = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleAssignments/22222222-2222-2222-2222-222222222222"
    }
    error_message = "Owner assignment IDs must preserve caller-chosen keys."
  }
}

run "contributor" {
  command = apply

  module {
    source = "../contributor"
  }

  assert {
    condition     = output.ids == run.owners.ids
    error_message = "Contributor assignment IDs must preserve caller-chosen keys."
  }
}

run "blob_storage_owner" {
  command = apply

  module {
    source = "../blob-storage-owner"
  }

  assert {
    condition     = output.ids == run.owners.ids
    error_message = "Storage Blob Data Owner assignment IDs must preserve caller-chosen keys."
  }
}

run "blob_storage_contributor" {
  command = apply

  module {
    source = "../blob-storage-contributor"
  }

  assert {
    condition     = output.ids == run.owners.ids
    error_message = "Storage Blob Data Contributor assignment IDs must preserve caller-chosen keys."
  }
}

run "owners_empty" {
  command = plan

  variables {
    assignments = {}
  }

  assert {
    condition     = length(output.ids) == 0
    error_message = "Empty Owner assignments must create no resources."
  }
}

run "contributor_empty" {
  command = plan

  module {
    source = "../contributor"
  }

  variables {
    assignments = {}
  }

  assert {
    condition     = length(output.ids) == 0
    error_message = "Empty Contributor assignments must create no resources."
  }
}

run "blob_storage_owner_empty" {
  command = plan

  module {
    source = "../blob-storage-owner"
  }

  variables {
    assignments = {}
  }

  assert {
    condition     = length(output.ids) == 0
    error_message = "Empty Storage Blob Data Owner assignments must create no resources."
  }
}

run "blob_storage_contributor_empty" {
  command = plan

  module {
    source = "../blob-storage-contributor"
  }

  variables {
    assignments = {}
  }

  assert {
    condition     = length(output.ids) == 0
    error_message = "Empty Storage Blob Data Contributor assignments must create no resources."
  }
}
