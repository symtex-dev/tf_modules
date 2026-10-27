# Azure Blob Static Website Module

This Terraform module creates an Azure Storage Account configured for static website hosting.

## Usage

```hcl
module "blob_website" {
  source = "git::https://github.com/<ORG>/<REPO>.git//websites/blob-website"

  name                = "yourstorageacct"
  resource_group_name = "your-rg"
  location            = "East US"

  account_tier             = "Standard"
  account_replication_type = "LRS"

  index_document     = "index.html"
  error_document_404 = "404.html"

  tags = {
    environment = "dev"
  }
}
```

## Inputs
- `name`: Storage account name (3-24 lowercase letters/numbers)
- `resource_group_name`: Resource group name
- `location`: Azure region
- `account_tier`: Standard/Premium
- `account_replication_type`: LRS/GRS/etc
- `index_document`: Default index file
- `error_document_404`: 404 error file
- `tags`: Map of tags

## Outputs
- `primary_web_endpoint`: Website URL
- `storage_account_id`: Storage account resource ID
- `storage_account_name`: Storage account name

## Terragrunt Example

```hcl
terraform {
  source = "git::https://github.com/<ORG>/<REPO>.git//websites/blob-website"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  name                = "yourstorageacct"
  resource_group_name = "your-rg"
  location            = "East US"
}
```
