variable "name" {
	description = "Name of the Azure Key Vault."
	type        = string
}

variable "location" {
	description = "Azure region in which to create the Key Vault."
	type        = string
}

variable "resource_group_name" {
	description = "Name of the resource group for the Key Vault."
	type        = string
}

variable "tenant_id" {
	description = "Azure Active Directory tenant ID."
	type        = string
}

variable "sku_name" {
	description = "Key Vault SKU."
	type        = string
	default     = "standard"

	validation {
		condition     = contains(["standard", "premium"], var.sku_name)
		error_message = "sku_name must be either standard or premium."
	}
}

variable "soft_delete_retention_days" {
	description = "Number of days deleted vault items are retained."
	type        = number
	default     = 90
}

variable "purge_protection_enabled" {
	description = "Enable protection against permanently purging deleted items."
	type        = bool
	default     = true
}

variable "enabled_for_deployment" {
	description = "Allow Azure Virtual Machines to retrieve certificates as secrets."
	type        = bool
	default     = false
}

variable "enabled_for_disk_encryption" {
	description = "Allow Azure Disk Encryption to retrieve secrets and unwrap keys."
	type        = bool
	default     = false
}

variable "enabled_for_template_deployment" {
	description = "Allow Azure Resource Manager to retrieve secrets."
	type        = bool
	default     = false
}

variable "tags" {
	description = "Tags to apply to the Key Vault."
	type        = map(string)
	default     = {}
}