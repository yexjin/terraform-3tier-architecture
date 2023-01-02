## os image ##
data "openstack_images_image_v2" images {
  for_each = local.images

  name = each.value
  most_recent = true
}

## network ##
data "openstack_networking_subnet_v2" "subnets" {
  for_each = var.vpc_networks

  cidr = each.value.cidr
}

data "openstack_networking_network_v2" "external_network" {
  external = true
}

data "openstack_networking_network_v2" "vpc_networks" {
  for_each = var.vpc_networks

  matching_subnet_cidr = each.value.cidr
}


