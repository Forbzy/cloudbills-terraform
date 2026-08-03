output "namespace" {
  value = kubernetes_namespace.cloudbills.metadata[0].name
}