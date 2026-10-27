variable "workspace_name" {
  description = "Log Analytics workspace name."
  type        = string
}

variable "application_insights_name" {
  description = "Workspace-backed Application Insights name."
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

variable "retention_in_days" {
  description = "Log Analytics retention for the PerGB2018 pricing tier."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730 && floor(var.retention_in_days) == var.retention_in_days
    error_message = "Retention must be a whole number between 30 and 730 days."
  }
}

variable "application_type" {
  description = "Application Insights application type."
  type        = string
  default     = "web"

  validation {
    condition     = contains(["web", "other", "java", "MobileCenter"], var.application_type)
    error_message = "Choose web, other, java, or MobileCenter."
  }
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
