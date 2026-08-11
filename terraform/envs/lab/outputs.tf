output "deployment_mode" {
  value = var.deployment_mode
}

output "azure_summary" {
  value = var.enable_azure_platform ? module.azure_platform[0].summary : null
}

output "huawei_summary" {
  value = var.enable_huawei_platform ? module.huawei_platform[0].summary : null
}

output "kubernetes_namespaces" {
  value = var.enable_kubernetes_bootstrap ? module.kubernetes_platform[0].namespaces : []
}

output "huawei_kube_config_raw" {
  value     = var.enable_huawei_platform ? module.huawei_platform[0].kube_config_raw : null
  sensitive = true
}
