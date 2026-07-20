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

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.13.1"
  namespace  = "kube-system"
  timeout    = 600
  wait       = true

  values = [yamlencode({
    args = ["--kubelet-insecure-tls"]
  })]
}
