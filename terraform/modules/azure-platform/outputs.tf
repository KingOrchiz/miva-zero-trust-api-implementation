output "summary" {
  value = {
    provider                    = "azure"
    deployment_mode             = var.deployment_mode
    location                    = var.location
    resource_group_name         = local.resource_group_name
    existing_aks_cluster_name   = var.existing_aks_cluster_name
    creates_resource_group      = local.create_dedicated
    creates_key_vault           = local.create_dedicated
    creates_log_analytics       = local.create_dedicated
    kubernetes_cluster_deferred = true
  }
}
