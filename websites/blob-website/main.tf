resource "azurerm_storage_account" "this" {
	name                     = var.name
	resource_group_name      = var.resource_group_name
	location                 = var.location
	account_tier             = var.account_tier
	account_replication_type = var.account_replication_type

	static_website {
		index_document     = var.index_document
		error_404_document = var.error_document_404
	}

	tags = var.tags
}
