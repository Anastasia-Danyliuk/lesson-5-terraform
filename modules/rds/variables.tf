variable "use_aurora" {
  description = "Set to true to create Aurora Cluster, false for standard RDS"
  type        = bool
  default     = false
}

variable "engine" {
  description = "The database engine (e.g., postgres or mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "The database engine version"
  type        = string
  default     = "14"
}

variable "instance_class" {
  description = "The instance type (e.g., db.t3.micro)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "mydb"
}

variable "username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "List of subnet IDs for DB Subnet Group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for Security Group"
  type        = string
}