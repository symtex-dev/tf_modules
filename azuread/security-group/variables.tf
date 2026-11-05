variable "name" {
  description = "Display name of the security group."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The security group name must not be blank."
  }
}

variable "description" {
  description = "Optional description of the security group."
  type        = string
  default     = null
}

variable "owners" {
  description = "Additional Microsoft Entra object IDs to make owners. The Terraform execution identity is always included."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for owner in var.owners : length(trimspace(owner)) > 0])
    error_message = "Owner object IDs must not be blank."
  }
}

variable "members" {
  description = "Microsoft Entra object IDs of users, groups, or service principals to add as members."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for member in var.members : length(trimspace(member)) > 0])
    error_message = "Member object IDs must not be blank."
  }
}
