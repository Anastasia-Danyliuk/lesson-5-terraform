variable "argocd_version" {
  type    = string
  default = "7.8.28"
}

variable "cluster_name" { type = string }
variable "cluster_endpoint" { type = string }
variable "cluster_ca_certificate" { type = string }

variable "git_repository_url" {
  type = string
}

variable "git_revision" {
  type = string
}
