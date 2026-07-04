variable "repository_name" {
  description = "The name of the ECR repository"
  type        = string
}

variable "scan_on_push" {
  description = "Enable image scanning"
  type        = bool
  default     = true
}
