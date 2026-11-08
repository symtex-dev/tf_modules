variable "name" {
  description = "Azure VPN gateway name."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The VPN gateway name must not be blank."
  }
}

variable "resource_group_name" {
  description = "Existing resource group containing the hub VNet and VPN gateway."
  type        = string

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "The resource group name must not be blank."
  }
}

variable "location" {
  description = "Azure region for the VPN gateway and public IP."
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the existing hub VNet to receive the GatewaySubnet."
  type        = string

  validation {
    condition     = length(trimspace(var.virtual_network_name)) > 0
    error_message = "The hub VNet name must not be blank."
  }
}

variable "gateway_subnet_prefix" {
  description = "Unused IPv4 CIDR inside the hub VNet for the dedicated GatewaySubnet. Use /27 or larger."
  type        = string

  validation {
    condition = try(
      can(cidrnetmask(var.gateway_subnet_prefix)) &&
      tonumber(split("/", var.gateway_subnet_prefix)[1]) <= 27,
      false
    )
    error_message = "GatewaySubnet must be a valid IPv4 CIDR with a /27 or larger address range."
  }
}

variable "client_address_pool" {
  description = "Non-overlapping IPv4 CIDR ranges assigned to connected P2S clients."
  type        = list(string)

  validation {
    condition = (
      length(var.client_address_pool) > 0 &&
      alltrue([for prefix in var.client_address_pool : can(cidrnetmask(prefix))])
    )
    error_message = "Provide at least one valid IPv4 CIDR range for VPN clients."
  }
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID used for Azure VPN Client authentication."
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$", var.tenant_id))
    error_message = "Provide the Microsoft Entra tenant ID in GUID format."
  }
}

variable "sku" {
  description = "Azure VPN Gateway SKU. Basic does not support OpenVPN with Microsoft Entra authentication."
  type        = string
  default     = "VpnGw1"

  validation {
    condition = contains([
      "VpnGw1", "VpnGw2", "VpnGw3", "VpnGw4", "VpnGw5",
      "VpnGw1AZ", "VpnGw2AZ", "VpnGw3AZ", "VpnGw4AZ", "VpnGw5AZ"
    ], var.sku)
    error_message = "Use a supported VpnGw SKU; the Basic SKU is not supported."
  }
}

variable "generation" {
  description = "VPN Gateway generation."
  type        = string
  default     = "Generation1"

  validation {
    condition = (
      contains(["Generation1", "Generation2"], var.generation) &&
      (contains(["VpnGw1", "VpnGw1AZ"], var.sku) ? var.generation == "Generation1" : true) &&
      (contains(["VpnGw4", "VpnGw5", "VpnGw4AZ", "VpnGw5AZ"], var.sku) ? var.generation == "Generation2" : true)
    )
    error_message = "Use Generation1 or Generation2; VpnGw1 requires Generation1 and VpnGw4/5 require Generation2."
  }
}

variable "public_ip_zones" {
  description = "Availability zones for the Standard public IP, if supported in the selected region."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the VPN gateway and public IP."
  type        = map(string)
  default     = {}
}
