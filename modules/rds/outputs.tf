output "db_endpoint" {
  description = "The endpoint of the database"
  value       = var.use_aurora ? aws_rds_cluster.aurora[0].endpoint : aws_db_instance.default[0].endpoint
}