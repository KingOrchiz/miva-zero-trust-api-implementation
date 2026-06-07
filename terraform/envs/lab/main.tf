module "azure_aks" {
  source = "../../modules/azure-aks"

  project     = var.project
  environment = var.environment
  location    = var.azure_location
  tags        = var.tags
}

module "huawei_cce" {
  source = "../../modules/huawei-cce"

  project     = var.project
  environment = var.environment
  region      = var.huawei_region
  tags        = var.tags
}
