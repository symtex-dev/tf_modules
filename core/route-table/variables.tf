variable "name" {
  description = "Route table name."
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

variable "bgp_route_propagation_enabled" {
  description = "Propagate gateway BGP routes into the route table."
  type        = bool
  default     = true
}

variable "routes" {
  description = "Routes keyed by route name."
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for route in values(var.routes) :
      contains(["VirtualNetworkGateway", "VnetLocal", "Internet", "VirtualAppliance", "None"], route.next_hop_type) &&
      (route.next_hop_type == "VirtualAppliance" ? route.next_hop_in_ip_address != null : route.next_hop_in_ip_address == null)
    ])
    error_message = "Use a valid next hop type and supply a next hop IP only for VirtualAppliance routes."
  }
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}