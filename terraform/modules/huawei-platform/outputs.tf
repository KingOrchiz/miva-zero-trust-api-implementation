output "summary" {
  value = {
    project_display_name = var.project_display_name
    deployment_mode      = var.deployment_mode
    region               = var.region
    enterprise_project_id = var.enterprise_project_id
    vpc_id               = local.vpc_id
    subnet_id            = local.subnet_id
    cce_cluster_id       = local.cluster_id
    cce_cluster_name     = local.create_dedicated ? huaweicloud_cce_cluster.this[0].name : null
    swr_organization     = local.create_dedicated ? huaweicloud_swr_organization.this[0].name : null
    lts_group_name       = local.create_dedicated ? huaweicloud_lts_group.this[0].group_name : null
    node_flavor_id       = local.create_dedicated && var.create_node_pool ? var.node_flavor_id : null
    node_count           = local.create_dedicated && var.create_node_pool ? var.node_count : null
  }
}
