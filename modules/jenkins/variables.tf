variable "cluster_name" { type = string }
variable "cluster_endpoint" { type = string }
variable "cluster_ca_certificate" { type = string }

variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  type = string
}

variable "github_username" { type = string }

variable "github_token" {
  type      = string
  sensitive = true
}
