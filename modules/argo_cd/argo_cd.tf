resource "kubernetes_namespace_v1" "argocd" {
  metadata { name = "argocd" }
}

resource "helm_release" "argocd" {
  name       = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_version
  namespace  = kubernetes_namespace_v1.argocd.metadata[0].name
  timeout    = 900
  wait       = true

  values = [file("${path.module}/values.yaml")]
}

resource "helm_release" "applications" {
  name      = "argocd-applications"
  chart     = "${path.module}/charts"
  namespace = kubernetes_namespace_v1.argocd.metadata[0].name
  wait      = true

  set = [
    { name = "repository.url", value = var.git_repository_url },
    { name = "application.revision", value = var.git_revision }
  ]

  depends_on = [helm_release.argocd]
}

data "kubernetes_service_v1" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace_v1.argocd.metadata[0].name
  }

  depends_on = [helm_release.argocd]
}
