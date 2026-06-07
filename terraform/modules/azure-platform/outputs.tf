output "summary" {
  value = {
    project_display_name         = var.project_display_name
    deployment_mode              = var.deployment_mode
    location                     = var.location
    resource_group_name          = local.resource_group_name
    aks_cluster_name             = local.aks_cluster_name
    container_registry_name      = local.create_dedicated ? azurerm_container_registry.this[0].name : null
    log_analytics_workspace_name = local.create_dedicated ? azurerm_log_analytics_workspace.this[0].name : null
    vnet_name                    = local.create_dedicated ? azurerm_virtual_network.this[0].name : null
    aks_subnet_name              = local.create_dedicated ? azurerm_subnet.aks[0].name : null
    node_size                    = local.create_dedicated ? var.aks_vm_size : null
    node_min_count               = local.create_dedicated ? var.aks_min_count : null
    node_max_count               = local.create_dedicated ? var.aks_max_count : null
  }
}
