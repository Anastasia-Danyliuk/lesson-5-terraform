output "s3_bucket_arn" {
  value = module.s3_backend.s3_bucket_arn
}

output "dynamodb_table_name" {
  value = module.s3_backend.dynamodb_table_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecr_url" {
  value = module.ecr.repository_url
}

output "db_endpoint" {
  description = "Address of the created RDS or Aurora database."
  value       = module.rds.db_endpoint
}
