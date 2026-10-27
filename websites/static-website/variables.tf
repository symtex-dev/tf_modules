variable "prefix" {
  description = "Prefix used to construct the static web app name."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the static web app."
  type        = string
}

variable "location" {
  description = "Azure region in which to create the static web app."
  type        = string
}

variable "sku_size" {
  description = "SKU size for the static web app."
  type        = string
}

variable "tags" {
  description = "Tags to assign to the static web app."
  type        = map(string)
  default     = {}
}

variable "custom_domain" {
  description = "Optional subdomain to register using a CNAME in an existing Azure DNS zone. resource_group_name is the DNS zone's resource group."
  type = object({
    subdomain           = string
    zone_name           = string
    resource_group_name = string
  })
  default = null

  validation {
    condition = var.custom_domain == null ? true : (
      can(regex("^[A-Za-z0-9]([A-Za-z0-9-]{0,61}[A-Za-z0-9])?$", var.custom_domain.subdomain))
    )
    error_message = "custom_domain.subdomain must be a DNS label of 1-63 letters, digits or hyphens, without a leading or trailing hyphen (for example, dev). Apex domains are not supported."
  }

  validation {
    condition = var.custom_domain == null ? true : (
      can(regex("^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$", var.custom_domain.zone_name)) &&
      can(regex("\\S", var.custom_domain.resource_group_name))
    )
    error_message = "custom_domain must include a DNS zone name without a trailing dot and a non-empty DNS resource group name."
  }
}
