# Blob storage contributor

Assigns the Azure RBAC **Storage Blob Data Contributor** role for reading,
writing, and deleting blob containers and data. This is a data-plane role,
not the resource-management Contributor role.
Uses the shared [role-assignment module](../../../core/role-assignment/).

```hcl
module "blob_storage_contributor" {
  source = "git::https://github.com/symtex-dev/tf_modules.git//azuread/iam/blob-storage-contributor"

  assignments = {
    workload = {
      scope                            = module.storage.id
      principal_id                     = module.identity.principal_id
      skip_service_principal_aad_check = true
    }
  }
}
```

Use a storage account ID or a container resource ID such as
`<storage-account-id>/blobServices/default/containers/<container-name>` to limit
access. See the [IAM documentation](../README.md) for the shared module contract.
