variable "chart_version" {
  type        = string
  description = "Version of kube-prometheus-stack Helm chart"
  default     = "69.8.2"
}

variable "grafana_admin_password" {
  type      = string
  sensitive = true
}
