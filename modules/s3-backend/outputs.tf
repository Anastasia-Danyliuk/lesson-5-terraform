output "s3_bucket_name" {
  description = "Name of S3 bucket"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  description = "Name of DynamoDB table"
  value       = aws_dynamodb_table.terraform_locks.name
}