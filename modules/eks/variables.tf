variable "subnet_ids" {
  description = "List of subnets for EKS"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}
