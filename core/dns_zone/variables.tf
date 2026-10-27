variable "dns_zone_name" {
  description = "The name of the DNS zone."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}

# ── TXT record ────────────────────────────────────────────────

variable "create_txt_record" {
  description = "Whether to create a DNS TXT record."
  type        = bool
  default     = false
}

variable "txt_record_name" {
  description = "The name of the TXT record. Use \"@\" for the zone apex."
  type        = string
  default     = "@"
}

variable "txt_record_ttl" {
  description = "TTL in seconds for the TXT record."
  type        = number
  default     = 300
}

variable "txt_record_values" {
  description = "List of string values for the TXT record."
  type        = list(string)
  default     = []
}

# ── MX record ────────────────────────────────────────────────

variable "create_mx_record" {
  description = "Whether to create a DNS MX record."
  type        = bool
  default     = false
}

variable "mx_record_name" {
  description = "The name of the MX record. Use \"@\" for the zone apex."
  type        = string
  default     = "@"
}

variable "mx_record_ttl" {
  description = "TTL in seconds for the MX record."
  type        = number
  default     = 300
}

variable "mx_records" {
  description = "List of MX record entries with preference and exchange."
  type = list(object({
    preference = number
    exchange   = string
  }))
  default = []
}
