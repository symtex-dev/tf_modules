variable "name" {
  description = "Display name of the single-tenant app registration."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The app registration name must not be blank."
  }
}

variable "description" {
  description = "Optional description of the app registration."
  type        = string
  default     = null
}

variable "owners" {
  description = "Additional owner object IDs for the application and service principal. The executing principal is always included."
  type        = set(string)
  default     = []
}

variable "federated_credentials" {
  description = "OIDC trusts keyed by unique credential display name. Issuer and subject must exactly match incoming token claims."
  type = map(object({
    issuer      = string
    subject     = string
    audiences   = optional(list(string), ["api://AzureADTokenExchange"])
    description = optional(string)
  }))

  validation {
    condition     = length(var.federated_credentials) >= 1 && length(var.federated_credentials) <= 20
    error_message = "Provide between 1 and 20 federated credentials per application."
  }

  validation {
    condition = alltrue([
      for name, credential in var.federated_credentials :
      length(trimspace(name)) > 0 &&
      can(regex("^https://[^[:space:]]+$", credential.issuer)) &&
      length(trimspace(credential.subject)) > 0 &&
      length(credential.audiences) == 1 &&
      alltrue([for audience in credential.audiences : length(trimspace(audience)) > 0])
    ])
    error_message = "Each credential requires a nonblank name and subject, an HTTPS issuer, and exactly one nonblank audience."
  }

  validation {
    condition = length(distinct([
      for credential in var.federated_credentials : jsonencode([credential.issuer, credential.subject])
    ])) == length(var.federated_credentials)
    error_message = "Each issuer and subject combination must be unique within the application."
  }
}