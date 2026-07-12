resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argo-cd-release"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_version

  namespace = kubernetes_namespace_v1.argocd.metadata[0].name

  timeout = 300
  wait    = false

  values = [
    file("${path.module}/values.yaml")
  ]
}