output "resource_group_name" {
  value = var.resource_group_name
}

output "vnet_id" {
  value = module.vnet.id
}

output "vnet_name" {
  value = module.vnet.name
}

output "subnet_ids" {
  # Preserve child-module keys so callers can select a subnet by its name.
  value = { for name, subnet in module.subnets : name => subnet.id }
}

output "nsg_id" {
  value = module.nsg.id
}

output "route_table_id" {
  value = try(module.route_table["network"].id, null)
}

output "spoke_to_hub_peering_id" {
  value = module.peering.local_to_remote_peering_id
}

output "hub_to_spoke_peering_id" {
  value = module.peering.remote_to_local_peering_id
}