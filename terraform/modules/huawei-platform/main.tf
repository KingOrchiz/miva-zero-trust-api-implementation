locals {
  prefix           = "${var.project}-${var.environment}"
  compact_prefix   = replace(local.prefix, "-", "")
  create_dedicated = var.deployment_mode == "dedicated-lab"

  vpc_id     = local.create_dedicated ? huaweicloud_vpc.this[0].id : var.existing_vpc_id
  subnet_id  = local.create_dedicated ? huaweicloud_vpc_subnet.this[0].id : var.existing_subnet_id
  cluster_id = local.create_dedicated ? huaweicloud_cce_cluster.this[0].id : var.existing_cce_cluster_id
}

resource "huaweicloud_vpc" "this" {
  count  = local.create_dedicated ? 1 : 0
  region = var.region
  name   = "vpc-${local.prefix}"
  cidr                  = var.vpc_cidr
  enterprise_project_id = var.enterprise_project_id
}

resource "huaweicloud_vpc_subnet" "this" {
  count      = local.create_dedicated ? 1 : 0
  region     = var.region
  name       = "subnet-cce-${local.prefix}"
  cidr       = var.subnet_cidr
  gateway_ip = var.subnet_gateway_ip
  vpc_id                = huaweicloud_vpc.this[0].id
}


resource "huaweicloud_lts_group" "this" {
  count       = local.create_dedicated ? 1 : 0
  region      = var.region
  group_name            = "lts-${local.prefix}"
  ttl_in_days           = 30
  enterprise_project_id = var.enterprise_project_id
}

resource "huaweicloud_lts_stream" "cce" {
  count       = local.create_dedicated ? 1 : 0
  region      = var.region
  group_id    = huaweicloud_lts_group.this[0].id
  stream_name = "cce-${local.prefix}"
  ttl_in_days = 30
}

resource "huaweicloud_cce_cluster" "this" {
  count                  = local.create_dedicated ? 1 : 0
  region                 = var.region
  name                   = "cce-${local.prefix}"
  flavor_id              = var.cluster_flavor_id
  enterprise_project_id  = var.enterprise_project_id
  vpc_id                 = huaweicloud_vpc.this[0].id
  subnet_id              = huaweicloud_vpc_subnet.this[0].id
  container_network_type = "overlay_l2"
  description            = "Lean dedicated lab cluster for ${var.project_display_name} MIVA prototype"
}

resource "huaweicloud_cce_node_pool" "this" {
  count              = local.create_dedicated && var.create_node_pool ? 1 : 0
  region             = var.region
  cluster_id         = huaweicloud_cce_cluster.this[0].id
  name               = "np-${local.prefix}"
  flavor_id          = var.node_flavor_id
  initial_node_count    = var.node_count
  enterprise_project_id = var.enterprise_project_id
  os                    = "EulerOS 2.9"
  key_pair              = var.node_auth_mode == "key_pair" && var.node_key_pair != "" ? var.node_key_pair : null
  password              = var.node_auth_mode == "password" ? var.node_password : null

  root_volume {
    size       = 40
    volumetype = "SAS"
  }

  data_volumes {
    size       = 100
    volumetype = "SAS"
  }

}
