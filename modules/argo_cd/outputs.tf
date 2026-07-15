output "argocd_namespace" {
  value = kubernetes_namespace_v1.argocd.metadata[0].name
}

output "argocd_server_url" {
  description = "Command that returns the external Argo CD server hostname."
  value       = "kubectl -n ${kubernetes_namespace_v1.argocd.metadata[0].name} get service ${helm_release.argocd.name}-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

output "argocd_admin_password_command" {
  description = "Command that returns the initial Argo CD admin password."
  value       = "kubectl -n ${kubernetes_namespace_v1.argocd.metadata[0].name} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode"
}
