output "summary" {
  value = {
    provider                    = "huawei"
    deployment_mode             = var.deployment_mode
    region                      = var.region
    existing_cce_cluster_id     = var.existing_cce_cluster_id
    existing_vpc_id             = var.existing_vpc_id
    existing_subnet_id          = var.existing_subnet_id
    creates_dedicated_resources = local.create_dedicated
    kubernetes_cluster_deferred = true
  }
}
