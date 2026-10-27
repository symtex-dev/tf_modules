variable "name" {
  description = "Base name used for the Container Apps environment, Log Analytics workspace, and app."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group where resources are created."
  type        = string
}

variable "location" {
  description = "Azure region for the Container Apps resources."
  type        = string
}

variable "container_image" {
  description = "Container image, including registry and tag, to run."
  type        = string
}

variable "environment_name" {
  description = "Optional Container Apps environment name. Defaults to <name>-env."
  type        = string
  default     = null
}

variable "infrastructure_subnet_id" {
  description = "Optional existing dedicated subnet ID for environment VNet integration. Consumption-only environments require /23 or larger. Changing this replaces the environment."
  type        = string
  default     = null
}

variable "internal_load_balancer_enabled" {
  description = "Use a private environment ingress address instead of a public address. Requires infrastructure_subnet_id."
  type        = bool
  default     = false
  nullable    = false
}

variable "container_app_name" {
  description = "Optional Container App name. Defaults to <name>-app."
  type        = string
  default     = null
}

variable "log_analytics_workspace_name" {
  description = "Optional Log Analytics workspace name. Defaults to <name>-logs."
  type        = string
  default     = null
}

variable "log_analytics_sku" {
  description = "SKU for the Log Analytics workspace."
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Log retention period in days."
  type        = number
  default     = 30
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

variable "container_name" {
  description = "Name of the container within the Container App."
  type        = string
  default     = "app"
}

variable "environment_variables" {
  description = "Non-secret environment variables passed to the application container."
  type        = map(string)
  default     = {}
}

variable "cpu" {
  description = "CPU cores allocated to the container."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory allocated to the container, for example 0.5Gi."
  type        = string
  default     = "0.5Gi"
}

variable "revision_mode" {
  description = "Revision mode for the Container App."
  type        = string
  default     = "Single"
  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision_mode must be Single or Multiple."
  }
}

variable "ingress" {
  description = "Optional ingress configuration. Set to null to keep the app private."
  type = object({
    external_enabled = bool
    target_port      = number
    transport        = string
  })
  default = null
  validation {
    condition = var.ingress == null || (
      var.ingress.target_port >= 1 && var.ingress.target_port <= 65535 &&
      contains(["auto", "http", "http2", "tcp"], var.ingress.transport)
    )
    error_message = "Ingress target_port must be between 1 and 65535 and transport must be auto, http, http2, or tcp."
  }
}

variable "tags" {
  description = "Tags applied to resources created by this module."
  type        = map(string)
  default     = {}
}

variable "registries" {
  description = "List of container registries and authentication configs (passwords or identities)."
  type = list(object({
    server               = string
    username             = optional(string)
    password_secret_name = optional(string)
    identity             = optional(string)
  }))
  default = []
}

variable "secrets" {
  description = "List of secrets to configure on the Container App."
  type = list(object({
    name  = string
    value = string
  }))
  default   = []
  sensitive = true
}

variable "identity_type" {
  description = "Type of managed service identity (e.g., None, SystemAssigned, UserAssigned)."
  type        = string
  default     = null
}

variable "identity_ids" {
  description = "List of User Assigned Managed Identity IDs when identity_type includes UserAssigned."
  type        = list(string)
  default     = null
}

variable "secret_environment_variables" {
  type    = map(string)
  default = {}
}
