output "azure_cluster_name" {
  value = module.azure_aks.cluster_name
}

output "huawei_cluster_name" {
  value = module.huawei_cce.cluster_name
}
