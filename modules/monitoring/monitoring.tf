resource "kubernetes_namespace_v1" "monitoring" {
  metadata { name = "monitoring" }
}

resource "helm_release" "monitoring" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  timeout    = 1200
  wait       = true

  values = [file("${path.module}/values.yaml")]

  set_sensitive = [{
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }]
}
