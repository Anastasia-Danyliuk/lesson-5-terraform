variable "aws_region" {
  type        = string
  description = "AWS region for all resources."
  default     = "us-east-1"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name."
  default     = "django-eks-cluster"
}

variable "ecr_repository_name" {
  type        = string
  description = "ECR repository name."
  default     = "lesson-5-ecr"
}

variable "git_repository_url" {
  type        = string
  description = "Git repository watched by Argo CD."
  default     = "https://github.com/Anastasia-Danyliuk/lesson-5-terraform.git"
}

variable "git_revision" {
  type        = string
  description = "Git branch watched by Argo CD and updated by Jenkins."
  default     = "lesson-8-9"
}

variable "jenkins_aws_access_key_id" {
  type        = string
  description = "AWS access key used by Kaniko to push to ECR."
  sensitive   = true
}

variable "jenkins_aws_secret_access_key" {
  type        = string
  description = "AWS secret key used by Kaniko to push to ECR."
  sensitive   = true
}

variable "github_username" {
  type        = string
  description = "GitHub username used by the Jenkins pipeline."
  default     = "Anastasia-Danyliuk"
}

variable "github_token" {
  type        = string
  description = "GitHub fine-grained token with Contents read/write permission."
  sensitive   = true
}
