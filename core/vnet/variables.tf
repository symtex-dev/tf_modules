variable "name" {
  description = "Virtual network name."
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "address_space" {
  description = "Non-overlapping IPv4 or IPv6 CIDR ranges."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0 && alltrue([for prefix in var.address_space : can(cidrhost(prefix, 0))])
    error_message = "Provide at least one valid CIDR range."
  }
}

variable "dns_servers" {
  description = "Custom DNS servers; an empty list uses Azure DNS."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}