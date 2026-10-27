variable "peering" {
  description = "Optional bidirectional peering. Local is the spoke; remote is the hub. The remote provider owns the reverse peering."
  type = object({
    local_to_remote_name       = string
    remote_to_local_name       = string
    local_resource_group_name  = string
    local_virtual_network_name = string
    local_virtual_network_id   = string
    remote_resource_group_name = string
    remote_virtual_network_name = string
    remote_virtual_network_id   = string
    allow_forwarded_traffic     = optional(bool, true)
    use_remote_gateways         = optional(bool, false)
  })
  default = null
}

variable "vpn_gateway" {
  description = "Optional single-instance route-based VPN gateway. subnet_id must identify GatewaySubnet."
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    subnet_id           = string
    sku                 = optional(string, "VpnGw1")
    generation          = optional(string, "Generation1")
    public_ip_zones     = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.vpn_gateway == null ? true : (
      contains(["VpnGw1", "VpnGw2", "VpnGw3", "VpnGw4", "VpnGw5", "VpnGw1AZ", "VpnGw2AZ", "VpnGw3AZ", "VpnGw4AZ", "VpnGw5AZ"], var.vpn_gateway.sku) &&
      contains(["Generation1", "Generation2"], var.vpn_gateway.generation) &&
      (contains(["VpnGw4", "VpnGw5", "VpnGw4AZ", "VpnGw5AZ"], var.vpn_gateway.sku) ? var.vpn_gateway.generation == "Generation2" : true) &&
      (contains(["VpnGw1", "VpnGw1AZ"], var.vpn_gateway.sku) ? var.vpn_gateway.generation == "Generation1" : true)
    )
    error_message = "Use a supported VpnGw SKU and generation: VpnGw1 requires Generation1; VpnGw4/5 require Generation2."
  }
}

variable "vpn_connections" {
  description = "Site-to-site IPsec connections keyed by local network gateway name."
  type = map(object({
    gateway_address     = optional(string)
    gateway_fqdn        = optional(string)
    address_space       = list(string)
    connection_protocol = optional(string, "IKEv2")
  }))
  default = {}

  validation {
    condition = alltrue([
      for connection in values(var.vpn_connections) :
      (connection.gateway_address != null) != (connection.gateway_fqdn != null) &&
      length(connection.address_space) > 0 &&
      alltrue([for prefix in connection.address_space : can(cidrhost(prefix, 0))]) &&
      contains(["IKEv1", "IKEv2"], connection.connection_protocol)
    ])
    error_message = "Each connection needs exactly one gateway IP or FQDN, valid remote CIDRs, and IKEv1 or IKEv2."
  }
}

variable "vpn_shared_keys" {
  description = "IPsec shared keys keyed by connection name. Supply through a secret store or environment, not committed configuration. Keys remain in Terraform state."
  type        = map(string)
  sensitive   = true
  default     = {}

  validation {
    condition     = alltrue([for shared_key in values(var.vpn_shared_keys) : length(trimspace(shared_key)) > 0])
    error_message = "VPN shared keys must not be empty."
  }
}

variable "tags" {
  description = "Tags for VPN resources."
  type        = map(string)
  default     = {}
}