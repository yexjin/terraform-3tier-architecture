variable "prefix" {
  type = string
  default = "lena"
}

## ssh-key ##
variable "ssh_key" {
  type = string
  default = "my-keypair"
}

## network ##
variable "vpc_networks" {
  default = {
    edu-subnet-web = { cidr = "172.16.131.0/24" },
    edu-subnet-was = { cidr = "172.16.132.0/24" },
    edu-subnet-mgmt = { cidr = "172.16.133.0/24" }
  }
}

## security-groups ##
variable "security_groups" {
  default = {
    sg-mgmt = {
      description = "Security group for server management"
      rules = [
        {
          description       = "Allow SSH connection"
          direction         = "ingress"
          ethertype         = "IPv4"
          protocol          = "tcp"
          port_range_min    = 22
          port_range_max    = 22
          remote_group_name = "sg-bastion"
        },
        {
          description = "Allow ping"
          direction   = "ingress"
          ethertype   = "IPv4"
          protocol    = "icmp"
        },
      ]
    },
    sg-bastion = {
      description = "Security group for bastion host"
      rules = [
        {
          description    = "Allow manage connection"
          direction      = "ingress"
          ethertype      = "IPv4"
          protocol       = "tcp"
          port_range_min = 81
          port_range_max = 81
        },
        {
          description    = "Allow stream connection"
          direction      = "ingress"
          ethertype      = "IPv4"
          protocol       = "tcp"
          port_range_min = 10001
          port_range_max = 10099
        },
      ]
    }
    sg-web = {
      description = "Security group for web services"
      rules = [
        {
          description    = "Allow HTTP connection"
          direction      = "ingress"
          ethertype      = "IPv4"
          protocol       = "tcp"
          port_range_min = 80
          port_range_max = 80
        },
        {
          description    = "Allow HTTPS connection"
          direction      = "ingress"
          ethertype      = "IPv4"
          protocol       = "tcp"
          port_range_min = 443
          port_range_max = 443
        },
      ]
    },
    sg-was = {
      description = "Security group for was services"
      rules = [
        {
          description    = "Allow connection from web servers"
          direction      = "ingress"
          ethertype      = "IPv4"
          protocol       = "tcp"
          port_range_min = 8000
          port_range_max = 8000
        },
      ]
    },
  }
}

## instance ##
variable "instances" {
  default = {
    bastion_host = {
      flavor_name          = "a1-2-co"
      network_name         = "edu-subnet-mgmt"
      floating_ip_attached = true
      security_groups      = ["sg-mgmt"]
      key_pair             = "lena-key-27"
      image = [
        { size = 25, image_name = "Edu-Bastion", image_id = 0 }
      ]
      volumes = []
    },
    web01 = {
      flavor_name     = "a1-2-co"
      network_name    = "edu-subnet-web"
      security_groups = ["sg-web", "sg-mgmt"]
      key_pair        = "lena-key-27"
      image = [
        { size = 25, image_name = "Ubuntu 20.04", image_id = 1 }
      ]
      volumes = [
        { type = "block", size = 30, volume_name = "web01-volume" },
        { type = "object", size = }
      ]
    },
    web02 = {
      flavor_name     = "a1-2-co"
      network_name    = "edu-subnet-web"
      security_groups = ["sg-web", "sg-mgmt"]
      key_pair        = "lena-key-27"
      image = [
        { size = 25, image_name = "Ubuntu 20.04" }
      ]
      volumes = [
        { type = "block", size = 30, volume_name = "web02-volume" }
      ]
    },
    was01 = {
      flavor_name     = "a1-2-co"
      network_name    = "edu-subnet-was"
      security_groups = ["sg-was", "sg-mgmt"]
      key_pair        = "lena-key-27"
      image = [
        { size = 25, image_name = "CentOS 7.9" }
      ]
      volumes = [
        { type = "block", size = 30, volume_name = "was01-volume" }
      ]
    },
    was02 = {
      flavor_name     = "a1-2-co"
      network_name    = "edu-subnet-was"
      security_groups = ["sg-was", "sg-mgmt"]
      key_pair        = "lena-key-27"
      image = [
        { size = 25, image_name = "CentOS 7.9" }
      ]
      volumes = [
        { type = "block", size = 30, volume_name = "was02-volume" }
      ]
    },
  }
}


## LoadBalancers ##
variable "loadbalancers" {
  default = {
    lb-web = {
      vip_subnet_name = "edu-subnet-web"
      floating_ip_attached = true
    },
    lb-was = {
      vip_subnet_name = "edu-subnet-was"
    }
  }
}

variable "lb-listeners" {
  default = {
    web_service = {
      loadbalancer_name = "lb-web"
      protocol          = "HTTP"
      protocol_port     = 80
      insert_headers = {
        X-Forwarded-For = "true"
      }
    },
    was_service = {
      loadbalancer_name = "lb-was"
      protocol          = "HTTP"
      protocol_port     = 8000
      insert_headers = {
        X-Forwarded-For = "true"
      }
    }
  }
}

variable "lb-pools" {
  default = {
    web_servers = {
      listener_name = "web_service"
      protocol      = "HTTP"
      lb_method     = "ROUND_ROBIN"
      members = {
        web01 = { protocol_port = 80 },
        web02 = { protocol_port = 80 },
      }
    },
    was_servers = {
      listener_name = "was_service"
      protocol      = "HTTP"
      lb_method     = "ROUND_ROBIN"
      members = {
        was01 = { protocol_port = 8000 },
        was02 = { protocol_port = 8000 },
      }
    },
  }
}

