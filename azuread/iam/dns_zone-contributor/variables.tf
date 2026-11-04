variable "assignments" {
  description = "DMS ZONE assignments keyed by stable caller-chosen names. Principal IDs must be Microsoft Entra object IDs, not application client IDs."
  type = map(object({
    scope                            = string
    principal_id                     = string
    skip_service_principal_aad_check = optional(bool, false)
  }))
  default = {}
}
