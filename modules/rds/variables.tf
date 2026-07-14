variable "vpc_id" {
  type        = string
  description = "VPC where the database will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for RDS"
}

variable "allowed_cidr" {
  type        = string
  description = "CIDR that can connect to PostgreSQL"
}

variable "db_name" {
  type    = string
  default = "django_db"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}
