variable "name" {
  description = "Hub VNet name and prefix for network resources."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create for the hub."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "address_space" {
  description = "Hub VNet CIDR ranges, non-overlapping with spoke and on-premises networks."
  type        = list(string)
}

variable "dns_servers" {
  description = "Custom DNS servers; an empty list uses Azure DNS."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Workload subnets keyed by name. GatewaySubnet is created separately when VPN is enabled."
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
    error_message = "Configure GatewaySubnet through vpn.gateway_subnet_prefixes instead."
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
  description = "Optional shared workload route table. GatewaySubnet never receives this table."
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

variable "vpn" {
  description = "Optional route-based VPN gateway and dedicated GatewaySubnet. Defaults do not create a gateway."
  type = object({
    gateway_subnet_prefixes = list(string)
    sku                    = optional(string, "VpnGw1")
    generation             = optional(string, "Generation1")
    public_ip_zones        = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.vpn == null ? true : (
      length(var.vpn.gateway_subnet_prefixes) == 1 && alltrue([
        for prefix in var.vpn.gateway_subnet_prefixes : try(tonumber(split("/", prefix)[1]) <= 27 && can(cidrnetmask(prefix)), false)
      ])
    )
    error_message = "Provide one IPv4 GatewaySubnet CIDR of /27 or larger."
  }
}

variable "vpn_connections" {
  description = "Site-to-site connections; requires vpn configuration."
  type = map(object({
    gateway_address     = optional(string)
    gateway_fqdn        = optional(string)
    address_space       = list(string)
    connection_protocol = optional(string, "IKEv2")
  }))
  default = {}
}

variable "vpn_shared_keys" {
  description = "Sensitive IPsec keys keyed by connection name. Keys are stored in state."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}