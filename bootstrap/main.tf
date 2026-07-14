terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "s3_backend" {
  source      = "../modules/s3-backend"
  bucket_name = var.bucket_name
  table_name  = var.table_name
}

output "s3_bucket_arn" { value = module.s3_backend.s3_bucket_arn }
output "dynamodb_table_name" { value = module.s3_backend.dynamodb_table_name }
