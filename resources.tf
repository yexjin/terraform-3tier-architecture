## Security group ##
resource "openstack_networking_secgroup_v2" "secgroup" {
  for_each = var.security_groups

  name        = each.key
  description = each.value.description
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rules" {
  for_each = { for rule in local.secgroup_rules : rule.id => rule }

  direction         = each.value.direction
  ethertype         = each.value.ethertype
  protocol          = each.value.protocol
  port_range_min    = each.value.port_range_min
  port_range_max    = each.value.port_range_max
  security_group_id = each.value.security_group_id
}


## Network ##
resource "openstack_networking_port_v2" "port" {
  for_each = var.instances

  network_id         = data.openstack_networking_network_v2.vpc_networks[each.value.network_name].id
  security_group_ids = [for sg in each.value.security_groups : openstack_networking_secgroup_v2.secgroup[sg].id]
}

## Block storage ##
resource "openstack_blockstorage_volume_v3" "volume" {
  for_each = { for volume in local.volumes : "${volume.id}" => volume }

  name     = each.key
  size     = each.value.size
  image_id = each.value.image_id
}