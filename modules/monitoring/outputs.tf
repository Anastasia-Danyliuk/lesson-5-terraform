output "namespace" {
  value = kubernetes_namespace_v1.monitoring.metadata[0].name
}

output "grafana_service" {
  value = "grafana"
}
