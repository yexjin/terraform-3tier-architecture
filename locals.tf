
# local 블록은 variable과 비슷하지만, 각종 명령어를 통해 동적으로 생성되는 값을 할당할 수 있다.
# for_each 를 위해 따로 정리할 리스트들
locals {
  secgroup_rules = flatten([
    for sg_k, sg_v in var.security_groups : [
      for i, rule in sg_v.rules : {
        id                = "${sg_k}-${i}"
        security_group_id = openstack_networking_secgroup_v2.secgroup[sg_k].id
        direction         = rule.direction
        ethertype         = rule.ethertype
        protocol          = rule.protocol
        port_range_min    = try(rule.port_range_min, null)
        port_range_max    = try(rule.port_range_max, null)
        remote_group_id   = contains(keys(rule), "remote_group_name") ? openstack_networking_secgroup_v2.secgroup[rule.remote_group_name].id : null
        remote_ip_prefix  = null
      }
    ]
  ])

  image = toset([
    for instance in var.instances : instance.image[0].image_name
  ])

  pool_members = flatten([
    for pool_k, pool_v in var.lb-pools : [
      for member_k, member_v in pool_v.members : {
        id            = "${pool_k}-${member_k}"
        pool_id       = openstack_lb_pool_v2.pools[pool_k].id
        address       = openstack_compute_instance_v2.instance[member_k].network.0.fixed_ip_v4
        subnet_id     = data.openstack_networking_subnet_v2.subnets[var.instances[member_k].network_name].id
        protocol_port = member_v.protocol_port
      }
    ]
  ])

  # Floating IP를 연결할 Port의 ID를 list로 만들어 둠
  floating_ip_assignees = flatten(concat(
    [
      for instance_k, instance_v in var.instances : {
      name    = instance_k
      port_id = openstack_networking_port_v2.port[instance_k].id
    } if try(instance_v.floating_ip_attached, false)
    ],
    [
      for lb_k, lb_v in var.loadbalancers : {
      name    = lb_k
      port_id = openstack_lb_loadbalancer_v2.loadbalancer[lb_k].vip_port_id
    } if try(lb_v.floating_ip_attached, false)
    ]
  ))
}