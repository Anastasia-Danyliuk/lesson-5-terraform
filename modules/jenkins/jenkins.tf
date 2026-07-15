resource "kubernetes_namespace_v1" "jenkins" {
  metadata { name = "jenkins" }
}

resource "kubernetes_secret_v1" "cicd_credentials" {
  metadata {
    name      = "jenkins-cicd-credentials"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }

  data = {
    github_username = var.github_username
    github_token    = var.github_token
  }

  type = "Opaque"
}

resource "kubernetes_secret_v1" "aws_credentials" {
  metadata {
    name      = "aws-credentials"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }

  data = {
    aws_access_key_id     = var.aws_access_key_id
    aws_secret_access_key = var.aws_secret_access_key
    region                = var.aws_region
  }

  type = "Opaque"
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = "5.8.110"
  namespace  = kubernetes_namespace_v1.jenkins.metadata[0].name
  timeout    = 900
  wait       = true

  values = [file("${path.module}/values.yaml")]

  depends_on = [
    kubernetes_secret_v1.cicd_credentials,
    kubernetes_secret_v1.aws_credentials
  ]
}
