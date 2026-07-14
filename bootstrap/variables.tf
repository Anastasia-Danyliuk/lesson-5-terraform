variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type    = string
  default = "terraform-state-nasti-8421"
}

variable "table_name" {
  type    = string
  default = "terraform-locks"
}
