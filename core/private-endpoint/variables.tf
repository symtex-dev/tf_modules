variable "name" {
  description = "Private endpoint name."
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

variable "subnet_id" {
  description = "Existing subnet ID. Configure subnet private endpoint network policies for your routing/NSG design."
  type        = string
}

variable "private_connection_resource_id" {
  description = "Target Private Link resource ID."
  type        = string
}

variable "subresource_names" {
  description = "Target service group IDs, for example [\"blob\"] or [\"vault\"]."
  type        = list(string)

  validation {
    condition     = length(var.subresource_names) > 0 && alltrue([for name in var.subresource_names : trimspace(name) != ""])
    error_message = "Provide at least one non-empty service subresource name."
  }
}

variable "private_dns_zone_ids" {
  description = "Existing private DNS zone IDs to associate. An empty list skips the DNS zone group."
  type        = list(string)
  default     = []
}

variable "is_manual_connection" {
  description = "Require approval by the target resource owner."
  type        = bool
  default     = false
}

variable "request_message" {
  description = "Optional approval request message, only for manual connections."
  type        = string
  default     = null
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
