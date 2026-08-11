locals {
  prefix           = "${var.project}-${var.environment}"
  compact_prefix   = replace(local.prefix, "-", "")
  create_dedicated = var.deployment_mode == "dedicated-lab"

  vpc_id     = local.create_dedicated ? huaweicloud_vpc.this[0].id : var.existing_vpc_id
  subnet_id  = local.create_dedicated ? huaweicloud_vpc_subnet.this[0].id : var.existing_subnet_id
  cluster_id = local.create_dedicated ? huaweicloud_cce_cluster.this[0].id : var.existing_cce_cluster_id
}

resource "huaweicloud_vpc" "this" {
  count                 = local.create_dedicated ? 1 : 0
  region                = var.region
  name                  = "vpc-${local.prefix}"
  cidr                  = var.vpc_cidr
  enterprise_project_id = var.enterprise_project_id
}

resource "huaweicloud_vpc_subnet" "this" {
  count      = local.create_dedicated ? 1 : 0
  region     = var.region
  name       = "subnet-cce-${local.prefix}"
  cidr       = var.subnet_cidr
  gateway_ip = var.subnet_gateway_ip
  vpc_id     = huaweicloud_vpc.this[0].id
}


resource "huaweicloud_lts_group" "this" {
  count                 = local.create_dedicated ? 1 : 0
  region                = var.region
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
  eip                    = local.create_dedicated ? huaweicloud_vpc_eip.cce_api[0].address : null

  depends_on = [huaweicloud_vpc_eip.cce_api]
}

# NAT Gateway for VPC internet egress (required for image pulls from Docker Hub, etc.)
resource "huaweicloud_vpc_eip" "nat" {
  count                 = local.create_dedicated ? 1 : 0
  region                = var.region
  enterprise_project_id = var.enterprise_project_id
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "bw-nat-${local.prefix}"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

resource "huaweicloud_nat_gateway" "this" {
  count                 = local.create_dedicated ? 1 : 0
  region                = var.region
  name                  = "nat-gw-${local.prefix}"
  description           = "NAT gateway for CCE VPC internet egress (image pulls)"
  spec                  = "1"
  vpc_id                = huaweicloud_vpc.this[0].id
  subnet_id             = huaweicloud_vpc_subnet.this[0].id
  enterprise_project_id = var.enterprise_project_id

  depends_on = [huaweicloud_vpc_subnet.this]
}

resource "huaweicloud_nat_snat_rule" "this" {
  count          = local.create_dedicated ? 1 : 0
  region         = var.region
  nat_gateway_id = huaweicloud_nat_gateway.this[0].id
  source_type    = 0
  cidr           = var.vpc_cidr
  floating_ip_id = huaweicloud_vpc_eip.nat[0].id
}

# EIP for CCE API server public access (kubectl from outside VPC)
resource "huaweicloud_vpc_eip" "cce_api" {
  count                 = local.create_dedicated ? 1 : 0
  region                = var.region
  enterprise_project_id = var.enterprise_project_id
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "bw-cce-api-${local.prefix}"
    size        = 5
    share_type  = "PER"
    charge_mode = "traffic"
  }
}

data "huaweicloud_cce_cluster_certificate" "existing" {
  count      = local.create_dedicated ? 0 : 1
  region     = var.region
  cluster_id = var.existing_cce_cluster_id
  duration   = 1
}

resource "huaweicloud_cce_node_pool" "this" {
  count                     = local.create_dedicated && var.create_node_pool ? 1 : 0
  region                    = var.region
  cluster_id                = huaweicloud_cce_cluster.this[0].id
  name                      = "np-${local.prefix}"
  flavor_id                 = var.node_flavor_id
  initial_node_count        = var.node_count
  ignore_initial_node_count = false
  enterprise_project_id     = var.enterprise_project_id
  # Huawei CCE rejected legacy EulerOS 2.9 for the current managed cluster version.
  # Use the current Huawei Cloud EulerOS line supported by newer CCE versions.
  os       = "Huawei Cloud EulerOS 2.0"
  key_pair = var.node_auth_mode == "key_pair" && var.node_key_pair != "" ? var.node_key_pair : null
  password = var.node_auth_mode == "password" ? var.node_password : null

  root_volume {
    size       = 40
    volumetype = "SAS"
  }

  data_volumes {
    size       = 100
    volumetype = "SAS"
  }

}
