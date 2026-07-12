resource "kubernetes_namespace_v1" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.1.3"
  namespace  = kubernetes_namespace_v1.jenkins.metadata[0].name
  timeout    = 600
  wait       = false

  values = [
    file("${path.module}/values.yaml")
  ]
}