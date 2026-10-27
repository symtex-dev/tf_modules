variable "resource_group_name" {
  description = "NSG resource group name."
  type        = string
}

variable "network_security_group_name" {
  description = "Existing network security group name. Do not mix standalone rules with inline NSG rules."
  type        = string
}

variable "rules" {
  description = "Security rules keyed by name. Specify exactly one singular, plural, or ASG selector for each address and port."
  type = map(object({
    description                                = optional(string)
    priority                                   = number
    direction                                  = string
    access                                     = string
    protocol                                   = string
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    source_application_security_group_ids      = optional(set(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    destination_application_security_group_ids = optional(set(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in values(var.rules) :
      rule.priority >= 100 && rule.priority <= 4096 && floor(rule.priority) == rule.priority &&
      contains(["Inbound", "Outbound"], rule.direction) &&
      contains(["Allow", "Deny"], rule.access) &&
      contains(["Tcp", "Udp", "Icmp", "Esp", "Ah", "*"], rule.protocol)
    ])
    error_message = "Rules need an integer priority from 100 to 4096 and valid direction, access, and protocol values."
  }

  validation {
    condition = alltrue([
      for rule in values(var.rules) :
      length([for selector in [rule.source_port_range != null, rule.source_port_ranges != null] : selector if selector]) == 1 &&
      length([for selector in [rule.destination_port_range != null, rule.destination_port_ranges != null] : selector if selector]) == 1 &&
      length([for selector in [rule.source_address_prefix != null, rule.source_address_prefixes != null, rule.source_application_security_group_ids != null] : selector if selector]) == 1 &&
      length([for selector in [rule.destination_address_prefix != null, rule.destination_address_prefixes != null, rule.destination_application_security_group_ids != null] : selector if selector]) == 1
    ])
    error_message = "Specify exactly one selector for each source/destination port and address."
  }

  validation {
    condition     = length(distinct([for rule in values(var.rules) : "${rule.direction}:${rule.priority}"])) == length(var.rules)
    error_message = "Priorities must be unique within each direction."
  }
}