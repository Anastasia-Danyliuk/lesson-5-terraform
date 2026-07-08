terraform {
  backend "s3" {
    bucket         = "terraform-state-nasti-8421"
    key            = "lesson-7/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}