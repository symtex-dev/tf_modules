variable "name" {
  description = "Globally unique PostgreSQL Flexible Server name."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region where PostgreSQL is created."
  type        = string
}

variable "zone" {
  description = "Optional availability zone for the server, such as 2 in UK South."
  type        = string
  default     = null
}

variable "administrator_login" {
  description = "PostgreSQL administrator username."
  type        = string
  default     = "pgadmin"
}

variable "administrator_password" {
  description = "Administrator password supplied by a secret source, not committed to source control."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "postgresql_version" {
  description = "PostgreSQL major version."
  type        = string
  default     = "16"
}

variable "sku_name" {
  description = "Compute SKU. B_Standard_B1ms is the smallest burstable option (1 vCore, 2 GiB RAM)."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Allocated storage in MiB. 32768 is the minimum (32 GiB); Azure cannot shrink it later."
  type        = number
  default     = 32768
}

variable "database_name" {
  description = "Optional application database to create."
  type        = string
  default     = null
}

variable "firewall_rules" {
  description = "Named public IPv4 allowlists. Empty by default, denying public connections."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to the server."
  type        = map(string)
  default     = {}
}

variable "private_endpoint" {
  description = "Optional private endpoint network configuration. Set both IDs to enable a private endpoint and its PostgreSQL private DNS zone link."
  type = object({
    virtual_network_id = string
    subnet_id          = string
  })
  default = null
}

variable "public_network_access_enabled" {
  description = "Whether the PostgreSQL server accepts public network connections. Set false to require private networking."
  type        = bool
  default     = true
}