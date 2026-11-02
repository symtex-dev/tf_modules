# Blob storage owner

Assigns the Azure RBAC **Storage Blob Data Owner** role for full access to blob
containers and data, including POSIX access control. This is a data-plane role,
not the resource-management Owner role.
Uses the shared [role-assignment module](../../../core/role-assignment/).

```hcl
module "blob_storage_owner" {
  source = "git::https://github.com/symtex-dev/tf_modules.git//azuread/iam/blob-storage-owner"

  assignments = {
    data_administrators = {
      scope        = module.storage.id
      principal_id = "11111111-1111-1111-1111-111111111111"
    }
  }
}
```

Use a storage account ID or a container resource ID such as
`<storage-account-id>/blobServices/default/containers/<container-name>` to limit
access. See the [IAM documentation](../README.md) for the shared module contract.
