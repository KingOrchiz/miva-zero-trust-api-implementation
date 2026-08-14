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

# Operational CCE credentials are intentionally not exported from Terraform.
# CCE client certificates are cluster-generation specific and can remain stale
# in state after an out-of-band replacement. Operators must obtain a fresh,
# short-lived kubeconfig directly from Huawei CCE.
