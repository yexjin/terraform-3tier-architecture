resource "openstack_compute_instance_v2" "instance" {
  for_each = var.instances
  name            = each.key
  flavor_name     = each.value.flavor_name
  key_pair        = each.value.key_pair
  image_id        = data.openstack_images_image_v2.images[each.value.image[0].image_name].id
  security_groups = each.value.security_groups

  block_device {
    uuid                  = data.openstack_images_image_v2.images[each.value.image[0].image_name].id
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = false
  }

  network {
    port = openstack_networking_port_v2.port[each.key].id
  }
}