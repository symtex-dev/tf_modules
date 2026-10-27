variable "dns_zone_name" {
  description = "The name of the DNS zone."
  type        = string
  default = null
}

variable "main_profile_name" {
  description = "The name of the CDN Front Door profile."
  type        = string
}

variable "main_profile_sku" {
  description = "The SKU of the CDN Front Door profile."
  type        = string
  default     = "Standard_AzureFrontDoor"
}

variable "main_endpoint_name" {
  description = "The name of the CDN Front Door endpoint."
  type        = string
}

variable "main_origin_group_name" {
  description = "The name of the CDN Front Door origin group."
  type        = string
}

variable "main_origin_name" {
  description = "The name of the CDN Front Door origin."
  type        = string
}

variable "main_origin_host_name" {
  description = "The host name of the CDN Front Door origin."
  type        = string
}

variable "certificate_name_check_enabled" {
  description = "Whether certificate name check is enabled."
  type        = bool
  default     = false
}

variable "main_custom_domain_name" {
  description = "The name of the CDN Front Door custom domain."
  type        = string
}

variable "certificate_type" {
  description = "The certificate type for TLS."
  type        = string
  default     = "ManagedCertificate"
}

variable "minimum_tls_version" {
  description = "The minimum TLS version."
  type        = string
  default     = "TLS12"
}

variable "main_route_name" {
  description = "The name of the CDN Front Door route."
  type        = string
}

variable "patterns_to_match" {
  description = "The patterns to match for the route."
  type        = list(string)
  default     = ["/*"]
}

variable "supported_protocols" {
  description = "The supported protocols for the route."
  type        = list(string)
  default     = ["Http", "Https"]
}

variable "main_firewall_policy_name" {
  description = "The name of the CDN Front Door firewall policy."
  type        = string
}

variable "firewall_policy_mode" {
  description = "The mode for the firewall policy."
  type        = string
  default     = "Prevention"
}

variable "main_security_policy_name" {
  description = "The name of the CDN Front Door security policy."
  type        = string
}


variable "tags" {
  description = "A map of tags to assign to the resource group."
  type        = map(string)
  default     = {}
}

variable "resource_group_name" {
    description = "value"
    type =  string  
}


variable "dns_zone_id" {
  type    = string
  default = null
}

variable "fd_dns_zone_name" {
  description = "The host name for the main Front Door custom domain (e.g. dev.domain.com or domain.com)."
  type        = string
  default     = null
}

variable "additional_custom_domains" {
  description = "Extra custom domains to attach (e.g. www). Empty for dev."
  type = list(object({
    name      = string  # CDN resource name e.g. "www-domain"
    host_name = string  # FQDN e.g. "www.domain.com"
    subdomain = string  # DNS record prefix e.g. "www"
  }))
  default = []
}

variable "apex_cname_name" {
  description = "Subdomain name to create a CNAME record for, pointing to the Front Door endpoint (e.g. 'dev'). Set to null to skip."
  type        = string
  default     = null
}

variable "create_apex_alias" {
  description = "Whether to create an apex alias A record (@) pointing to the Front Door profile. Use for prod apex domain (domain.com)."
  type        = bool
  default     = false
}

variable "dns_resource_group_name" {
  type = string
  default = null
  
}

variable "enable_diagnostics" {
  description = "Whether to enable the Front Door diagnostic setting."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace to send diagnostics to. Required when enable_diagnostics is true."
  type        = string
  default     = null
}

variable "prefix" {
  type = string
  default = null
}