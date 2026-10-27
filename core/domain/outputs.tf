output "domains" {
  description = "DNS zone details keyed by domain name."
  value = {
    for domain, zone in azurerm_dns_zone.this : domain => {
      id           = zone.id
      name         = zone.name
      name_servers = zone.name_servers
    }
  }
}