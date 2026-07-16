terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
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

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  vpc_name           = "lesson-8-9-vpc"
}

module "ecr" {
  source          = "./modules/ecr"
  repository_name = var.ecr_repository_name
}

module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name
  subnet_ids   = module.vpc.private_subnets
}

resource "kubernetes_storage_class_v1" "ebs_gp3" {
  metadata {
    name = "ebs-gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "gp3"
  }

  depends_on = [module.eks]
}

module "rds" {
  source       = "./modules/rds"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnets
  allowed_cidr = "10.0.0.0/16"
  db_name      = var.db_name
  db_username  = var.db_username
  db_password  = var.db_password
}

resource "kubernetes_namespace_v1" "django_app" {
  metadata { name = "django-app" }

  depends_on = [module.eks]
}

resource "kubernetes_secret_v1" "django_database" {
  metadata {
    name      = "django-database"
    namespace = kubernetes_namespace_v1.django_app.metadata[0].name
  }

  data = {
    DJANGO_SECRET_KEY = var.django_secret_key
    POSTGRES_HOST     = module.rds.endpoint
    POSTGRES_PORT     = tostring(module.rds.port)
    POSTGRES_DB       = module.rds.database_name
    POSTGRES_USER     = var.db_username
    POSTGRES_PASSWORD = var.db_password
  }

  type = "Opaque"
}

module "jenkins" {
  source                 = "./modules/jenkins"
  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  aws_access_key_id      = var.jenkins_aws_access_key_id
  aws_secret_access_key  = var.jenkins_aws_secret_access_key
  aws_region             = var.aws_region
  github_username        = var.github_username
  github_token           = var.github_token

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [module.eks]
}

module "argo_cd" {
  source                 = "./modules/argo_cd"
  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  git_repository_url     = var.git_repository_url
  git_revision           = var.git_revision

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [module.eks, kubernetes_secret_v1.django_database]
}

module "monitoring" {
  source                 = "./modules/monitoring"
  grafana_admin_password = var.grafana_admin_password

  providers = {
    kubernetes = kubernetes
    helm       = helm
  }

  depends_on = [module.eks]
}
