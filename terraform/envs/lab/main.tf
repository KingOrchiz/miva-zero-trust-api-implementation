locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, {
    managed_by      = "terraform"
    dissertation    = "miva"
    deployment_mode = var.deployment_mode
  })
}

module "azure_platform" {
  count  = var.enable_azure_platform ? 1 : 0
  source = "../../modules/azure-platform"

  project                      = var.project
  environment                  = var.environment
  deployment_mode              = var.deployment_mode
  location                     = var.azure_location
  existing_resource_group_name = var.azure_existing_resource_group_name
  existing_aks_cluster_name    = var.azure_existing_aks_cluster_name
  tags                         = local.common_tags
}

module "huawei_platform" {
  count  = var.enable_huawei_platform ? 1 : 0
  source = "../../modules/huawei-platform"

  project                 = var.project
  environment             = var.environment
  deployment_mode         = var.deployment_mode
  region                  = var.huawei_region
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
    "miva-system",
    "miva-identity",
    "miva-security",
    "miva-observability",
    "miva-apps"
  ]
}
