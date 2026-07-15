variable "use_aurora" {
  description = "True creates Aurora, false creates a standard RDS instance."
  type        = bool
  default     = false
}

variable "engine" {
  description = "Engine for standard RDS, for example postgres or mysql."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Engine version for standard RDS."
  type        = string
  default     = "14"
}

variable "instance_class" {
  description = "Instance class for RDS and Aurora."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the first database."
  type        = string
  default     = "mydb"
}

variable "username" {
  description = "Database administrator username."
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Database administrator password."
  type        = string
  sensitive   = true
}

variable "subnet_ids" {
  description = "Subnet IDs for the database subnet group."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the database is created."
  type        = string
}

variable "name" {
  description = "Name used for database resources."
  type        = string
  default     = "lesson-db"
}

variable "allocated_storage" {
  description = "Storage size in GB for standard RDS."
  type        = number
  default     = 20
}

variable "multi_az" {
  description = "Create standard RDS in multiple availability zones."
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "Allow a public address for standard RDS."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to keep backups."
  type        = number
  default     = 7
}

variable "aurora_engine" {
  description = "Aurora engine: aurora-postgresql or aurora-mysql."
  type        = string
  default     = "aurora-postgresql"
}

variable "aurora_engine_version" {
  description = "Aurora engine version."
  type        = string
  default     = "14"
}

variable "aurora_instance_count" {
  description = "Number of instances in the Aurora cluster."
  type        = number
  default     = 1
}

variable "rds_parameter_group_family" {
  description = "Parameter group family for standard RDS."
  type        = string
  default     = "postgres14"
}

variable "aurora_parameter_group_family" {
  description = "Parameter group family for Aurora."
  type        = string
  default     = "aurora-postgresql14"
}

variable "parameters" {
  description = "Database parameters. Change them when using MySQL."
  type        = map(string)
  default = {
    max_connections = "100"
    log_statement   = "all"
    work_mem        = "16384"
  }
}

variable "from_port" {
  description = "Database port used in the Security Group ingress rule."
  type        = number
  default     = 5432
}

variable "cidr_blocks" {
  description = "VPC networks allowed to connect to the database."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "tags" {
  description = "Tags added to database resources."
  type        = map(string)
  default     = {}
}
