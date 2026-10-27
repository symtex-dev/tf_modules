output "resource_group_name" {
  value = module.resource_group.name
}

output "vnet_id" {
  value = module.vnet.id
}

output "vnet_name" {
  value = module.vnet.name
}

output "subnet_ids" {
  value = merge(
    { for name, subnet in module.subnets : name => subnet.id },
    var.vpn == null ? {} : { GatewaySubnet = module.gateway_subnet["gateway"].id }
  )
}

output "nsg_id" {
  value = module.nsg.id
}

output "route_table_id" {
  value = try(module.route_table["network"].id, null)
}

output "vpn_gateway_id" {
  value = module.vpn.vpn_gateway_id
}

output "vpn_public_ip" {
  value = module.vpn.vpn_public_ip
}

output "vpn_connection_ids" {
  value = module.vpn.vpn_connection_ids
}