variable "name" {
  description = "Prefix for foundation resource names."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create for the foundation."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "log_retention_in_days" {
  description = "Log Analytics retention, validated by the monitoring module."
  type        = number
  default     = 30
}

variable "storage" {
  description = "Optional blob storage and identity access. Private networking can use an existing subnet/VNet. Omit private_endpoint only when DNS/connectivity is managed separately or public access is explicitly enabled."
  type = object({
    name                          = string
    replication_type              = optional(string, "LRS")
    public_network_access_enabled = optional(bool, false)
    private_endpoint = optional(object({
      subnet_id          = string
      virtual_network_id = string
    }))
  })
  default = null
}

variable "tags" {
  description = "Tags applied to all supporting resources."
  type        = map(string)
  default     = {}
}
