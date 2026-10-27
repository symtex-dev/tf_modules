variable "name" {
  description = "Subnet name."
  type        = string
}

variable "resource_group_name" {
  description = "Virtual network resource group name."
  type        = string
}

variable "virtual_network_name" {
  description = "Existing virtual network name."
  type        = string
}

variable "address_prefixes" {
  description = "Subnet CIDR ranges within the virtual network address space."
  type        = list(string)

  validation {
    condition     = length(var.address_prefixes) > 0 && alltrue([for prefix in var.address_prefixes : can(cidrhost(prefix, 0))])
    error_message = "Provide at least one valid subnet CIDR range."
  }
}

variable "service_endpoints" {
  description = "Azure service endpoints enabled on the subnet."
  type        = list(string)
  default     = []
}

variable "private_endpoint_network_policies" {
  description = "Private endpoint network policy mode."
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], var.private_endpoint_network_policies)
    error_message = "Use Disabled, Enabled, NetworkSecurityGroupEnabled, or RouteTableEnabled."
  }
}

variable "delegations" {
  description = "Service delegations keyed by delegation name."
  type = map(object({
    service_name = string
    actions      = optional(list(string), [])
  }))
  default = {}
}

variable "network_security_group" {
  description = "Optional NSG attachment; wrap the ID in an object to keep resource counts known during planning."
  type        = object({ id = string })
  default     = null
}

variable "route_table" {
  description = "Optional route table attachment."
  type        = object({ id = string })
  default     = null
}