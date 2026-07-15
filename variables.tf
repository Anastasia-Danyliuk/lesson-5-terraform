variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "use_aurora" {
  description = "True creates Aurora, false creates standard RDS."
  type        = bool
  default     = false
}

variable "db_engine" {
  description = "Engine for standard RDS."
  type        = string
  default     = "postgres"
}

variable "db_instance_class" {
  description = "Database instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "Database administrator username."
  type        = string
  default     = "postgresuser"
}

variable "db_password" {
  description = "Database administrator password. Set it in terraform.tfvars."
  type        = string
  sensitive   = true
}
