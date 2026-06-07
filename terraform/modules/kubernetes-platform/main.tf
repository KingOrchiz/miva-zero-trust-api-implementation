resource "kubernetes_namespace" "this" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.value
    labels = {
      "app.kubernetes.io/part-of"     = var.project
      "app.kubernetes.io/environment" = var.environment
      "miva.openclaw.io/purpose"      = "chapter4-prototype"
    }
  }
}
