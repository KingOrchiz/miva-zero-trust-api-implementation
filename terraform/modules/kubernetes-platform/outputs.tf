output "namespaces" {
  value = [for ns in kubernetes_namespace.this : ns.metadata[0].name]
}
