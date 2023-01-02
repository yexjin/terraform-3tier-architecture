resource "openstack_lb_loadbalancer_v2" "loadbalancer" {
  for_each = var.loadbalancers

  name = each.key
  vip_subnet_id = data.openstack_networking_subnet_v2.subnets[each.value.vip_subnet_name].id
}

resource "openstack_lb_listener_v2" "listener" {
  for_each = var.lb-listeners

  name = each.key
  loadbalancer_id = openstack_lb_loadbalancer_v2.loadbalancer[each.value.loadbalancer_name].id
  protocol = each.value.protocol
  protocol_port = each.value.protocol_port
  insert_headers = each.value.insert_headers
}

resource "openstack_lb_pool_v2" "pools" {
  for_each = var.lb-pools

  name = each.key
  listener_id = openstack_lb_listener_v2.listener[each.value.listener_name].id
  lb_method = each.value.lb_method
  protocol  = each.value.protocol
}

resource "openstack_lb_member_v2" "member" {
  for_each = { for member in local.pool_members : "${member.id}" => member }
  pool_id       = each.value.pool_id
  address       = each.value.address
  protocol_port = each.value.protocol_port
  subnet_id     = each.value.subnet_id
}

resource "openstack_networking_floatingip_v2" "floating_ip" {
  for_each = { for fip_assignee in local.floating_ip_assignees : fip_assignee.name => fip_assignee }

  pool = data.openstack_networking_network_v2.external_network.name
}

resource "openstack_networking_floatingip_associate_v2" "fip_associate" {
  for_each = { for fip_assignee in local.floating_ip_assignees : fip_assignee.name => fip_assignee }

  floating_ip = resource.openstack_networking_floatingip_v2.floating_ip[each.key].address
  port_id     = each.value.port_id
}