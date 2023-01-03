resource "openstack_compute_instance_v2" "instance" {
  for_each = var.instances

  name            = each.key
  flavor_name     = each.value.flavor_name
  key_pair        = each.value.key_pair
  security_groups = each.value.security_groups

  dynamic "block_device" {
    for_each = { for i, volume in each.value.volumes : "${i}" => volume }

    content {
      uuid                  = openstack_blockstorage_volume_v3.volume["${each.key}-disk-${block_device.key}"].id
      source_type           = "volume"
      destination_type      = "volume"
      boot_index            = block_device.key
      delete_on_termination = false
    }
  }

  network {
    port = openstack_networking_port_v2.port[each.key].id
  }
}