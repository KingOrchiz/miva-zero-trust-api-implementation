locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, {
    managed_by           = "terraform"
    dissertation         = "miva"
    deployment_mode      = var.deployment_mode
    project_display_name = var.project_display_name
  })
}

module "azure_platform" {
  count  = var.enable_azure_platform ? 1 : 0
  source = "../../modules/azure-platform"

  project                      = var.project
  project_display_name         = var.project_display_name
  environment                  = var.environment
  deployment_mode              = var.deployment_mode
  location                     = var.azure_location
  create_resource_group        = var.azure_create_resource_group
  address_space                = var.azure_address_space
  aks_subnet_prefixes          = var.azure_aks_subnet_prefixes
  aks_node_count               = var.azure_aks_node_count
  aks_min_count                = var.azure_aks_min_count
  aks_max_count                = var.azure_aks_max_count
  aks_vm_size                  = var.azure_aks_vm_size
  existing_resource_group_name = var.azure_existing_resource_group_name
  existing_aks_cluster_name    = var.azure_existing_aks_cluster_name
  tags                         = local.common_tags
}

module "huawei_platform" {
  count  = var.enable_huawei_platform ? 1 : 0
  source = "../../modules/huawei-platform"

  project                 = var.project
  project_display_name    = var.project_display_name
  environment             = var.environment
  deployment_mode         = var.deployment_mode
  region                  = var.huawei_region
  enterprise_project_id   = var.huawei_enterprise_project_id
  vpc_cidr                = var.huawei_vpc_cidr
  subnet_cidr             = var.huawei_subnet_cidr
  subnet_gateway_ip       = var.huawei_subnet_gateway_ip
  cluster_flavor_id       = var.huawei_cluster_flavor_id
  node_flavor_id          = var.huawei_node_flavor_id
  node_count              = var.huawei_node_count
  node_availability_zone  = var.huawei_node_availability_zone
  node_key_pair           = var.huawei_node_key_pair
  create_node_pool        = var.create_huawei_node_pool
  existing_cce_cluster_id = var.huawei_existing_cce_cluster_id
  existing_vpc_id         = var.huawei_existing_vpc_id
  existing_subnet_id      = var.huawei_existing_subnet_id
  tags                    = local.common_tags
}

module "kubernetes_platform" {
  count  = var.enable_kubernetes_bootstrap ? 1 : 0
  source = "../../modules/kubernetes-platform"

  project     = var.project
  environment = var.environment
  namespaces = [
    "irestrict-system",
    "irestrict-identity",
    "irestrict-security",
    "irestrict-observability",
    "irestrict-apps"
  ]
}
