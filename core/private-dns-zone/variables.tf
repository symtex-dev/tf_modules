variable "name" {
  description = "Private DNS zone name, for example privatelink.blob.core.windows.net."
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group name."
  type        = string
}

variable "virtual_network_links" {
  description = "VNet links keyed by stable link names. Leave registration disabled for Private Link zones."
  type = map(object({
    virtual_network_id   = string
    registration_enabled = optional(bool, false)
  }))
  default = {}
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
