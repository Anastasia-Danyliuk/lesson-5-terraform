terraform {
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

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "terraform-state-nasti-8421"
  table_name  = "terraform-locks"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_name           = "lesson-5-vpc"
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = "lesson-5-ecr"
  scan_on_push    = true
}

module "eks" {
  source     = "./modules/eks"
  subnet_ids = module.vpc.private_subnets
}

module "argo_cd" {
  source                 = "./modules/argo_cd"
  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [module.eks]
}

# module "jenkins" {
#   source                 = "./modules/jenkins"
#   cluster_name           = module.eks.cluster_name
#   cluster_endpoint       = module.eks.cluster_endpoint
#   cluster_ca_certificate = module.eks.cluster_certificate_authority_data
#
#   providers = {
#     kubernetes = kubernetes
#     helm       = helm
#   }
#
#   depends_on = [module.eks]
# }

module "rds" {
  source = "./modules/rds"

  name           = "lesson-db"
  use_aurora     = var.use_aurora
  engine         = var.db_engine
  instance_class = var.db_instance_class
  db_name        = var.db_name
  username       = var.db_username
  password       = var.db_password

  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnets
  allowed_cidr_blocks = ["10.0.0.0/16"]

  tags = {
    Project = "lesson-db-module"
  }
}
