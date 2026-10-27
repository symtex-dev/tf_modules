variable "domains" {
  description = "Public DNS zones to create, keyed by domain name. Each zone may optionally include A, AAAA, CNAME, MX, TXT, and SRV record sets."
  type = map(object({
    resource_group_name = string
    tags                = optional(map(string), {})
    record_sets = optional(object({
      a = optional(map(object({
        records = list(string)
        ttl     = optional(number, 300)
      })), {})
      aaaa = optional(map(object({
        records = list(string)
        ttl     = optional(number, 300)
      })), {})
      cname = optional(map(object({
        target = string
        ttl    = optional(number, 300)
      })), {})
      mx = optional(map(object({
        records = list(object({
          preference = number
          exchange   = string
        }))
        ttl = optional(number, 300)
      })), {})
      txt = optional(map(object({
        records = list(string)
        ttl     = optional(number, 300)
      })), {})
      srv = optional(map(object({
        records = list(object({
          priority = number
          weight   = number
          port     = number
          target   = string
        }))
        ttl = optional(number, 300)
      })), {})
    }), {})
  }))
}