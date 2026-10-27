variable "name" {
  description = "Spoke VNet name and prefix for network resources."
  type        = string
}

variable "resource_group_name" {
  description = "Existing project resource group in which to create the spoke network."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "address_space" {
  description = "Spoke CIDR ranges, non-overlapping with hub and other spokes."
  type        = list(string)
}

variable "dns_servers" {
  description = "Custom DNS servers; an empty list uses Azure DNS."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Workload subnets keyed by name."
  type = map(object({
    address_prefixes                  = list(string)
    service_endpoints                 = optional(list(string), [])
    private_endpoint_network_policies = optional(string, "Disabled")
    associate_nsg                     = optional(bool, true)
    associate_route_table             = optional(bool, true)
    delegations = optional(map(object({
      service_name = string
      actions      = optional(list(string), [])
    })), {})
  }))
  default = {}

  validation {
    condition     = !contains(keys(var.subnets), "GatewaySubnet")
    error_message = "Spokes do not create GatewaySubnet; configure a VPN gateway in the hub."
  }

  validation {
    condition = alltrue([
      for name, subnet in var.subnets :
      contains(["AzureFirewallSubnet", "AzureFirewallManagementSubnet"], name) ? !subnet.associate_nsg : true
    ])
    error_message = "Azure Firewall subnets must set associate_nsg to false."
  }
}

variable "security_rules" {
  description = "Standalone rules for the shared workload NSG; Azure default NSG rules still apply."
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
}

variable "route_table" {
  description = "Optional shared workload route table. Peering alone does not provide transitive spoke-to-spoke routing."
  type = object({
    bgp_route_propagation_enabled = optional(bool, true)
    routes = optional(map(object({
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })), {})
  })
  default = null
}

variable "hub" {
  description = "Optional existing hub to peer with. Enable remote gateways only after the hub gateway exists; the spoke must not have its own gateway."
  type = object({
    resource_group_name     = string
    vnet_name               = string
    vnet_id                 = string
    allow_forwarded_traffic = optional(bool, true)
    use_remote_gateways     = optional(bool, false)
  })
  default = null
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}