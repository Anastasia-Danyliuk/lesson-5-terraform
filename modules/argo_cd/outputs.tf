output "argocd_namespace" {
  value = kubernetes_namespace_v1.argocd.metadata[0].name
}

output "argocd_server_url" {
  value = try(
    "https://${data.kubernetes_service_v1.argocd_server.status[0].load_balancer[0].ingress[0].hostname}",
    "https://${data.kubernetes_service_v1.argocd_server.status[0].load_balancer[0].ingress[0].ip}",
    "LoadBalancer address is being created"
  )
}

output "argocd_admin_password_command" {
  value = "kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 --decode"
}
