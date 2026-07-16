output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecr_url" {
  value = module.ecr.repository_url
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "jenkins_namespace" {
  value = module.jenkins.namespace
}

output "argocd_namespace" {
  value = module.argo_cd.argocd_namespace
}

output "argocd_server_url" {
  value = module.argo_cd.argocd_server_url
}

output "argocd_admin_password_command" {
  value = module.argo_cd.argocd_admin_password_command
}

output "rds_endpoint" {
  value     = module.rds.endpoint
  sensitive = true
}

output "monitoring_namespace" {
  value = module.monitoring.namespace
}

output "grafana_service" {
  value = module.monitoring.grafana_service
}
