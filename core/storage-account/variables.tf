variable "name" {
  description = "Globally unique storage account name, 3-24 lowercase letters and digits."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account names must contain 3-24 lowercase letters or digits."
  }
}

variable "resource_group_name" {
  description = "Existing resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "replication_type" {
  description = "Standard storage replication type; availability depends on the region."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Choose LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS."
  }
}

variable "public_network_access_enabled" {
  description = "Allow the public endpoint. Defaults to private-only; create a private endpoint for data access."
  type        = bool
  default     = false
}

variable "shared_access_key_enabled" {
  description = "Enable shared-key authentication for clients that cannot use Microsoft Entra authentication."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
