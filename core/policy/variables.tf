variable "name" {
  description = "The name of the custom policy definition."
  type        = string
}

variable "display_name" {
  description = "The display name of the custom policy definition."
  type        = string
}

variable "description" {
  description = "The description of the policy definition."
  type        = string
  default     = null
}

variable "policy_rule" {
  description = "The policy rule as a Terraform object that will be encoded as JSON."
  type        = any
}

variable "policy_type" {
  description = "The policy definition type."
  type        = string
  default     = "Custom"

  validation {
    condition     = contains(["Custom", "NotSpecified"], var.policy_type)
    error_message = "policy_type must be Custom or NotSpecified."
  }
}

variable "mode" {
  description = "The policy evaluation mode."
  type        = string
  default     = "All"
}
