output "db_endpoint" {
  description = "The endpoint of the database"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.default[0].endpoint
}

output "endpoint" {
  description = "Database hostname"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.default[0].address
}

output "port" {
  description = "Database port"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].port : aws_db_instance.default[0].port
}

output "database_name" {
  description = "Database name"
  value       = var.db_name
}

output "security_group_id" {
  description = "Database Security Group ID"
  value       = aws_security_group.rds_sg.id
}
