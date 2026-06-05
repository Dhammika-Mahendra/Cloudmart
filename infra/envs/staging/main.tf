terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}-${var.team_id}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    Team        = var.team_id
    Owner       = var.owner_email
    ManagedBy   = "terraform"
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix               = local.name_prefix
  aws_region                = var.aws_region
  vpc_cidr                  = var.vpc_cidr
  az_count                  = var.az_count
  enable_nat_gateway        = var.enable_nat_gateway
  enable_gateway_endpoints  = var.enable_gateway_endpoints
  enable_flow_logs          = var.enable_flow_logs
  flow_log_retention_days   = var.flow_log_retention_days
  bastion_allowed_ssh_cidrs = var.bastion_allowed_ssh_cidrs
  tags                      = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_prefix = "cloudmart"
  images_to_keep    = 10
  tags              = local.common_tags
}

resource "aws_iam_policy" "user_service_rds_secret" {
  name        = "${local.name_prefix}-user-service-rds-secret-policy"
  description = "Allow user-service to read only the CloudMart RDS credential secret."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = module.rds.secret_arn
      }
    ]
  })

  tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  name_prefix             = local.name_prefix
  cluster_version         = var.eks_cluster_version
  subnet_ids              = module.network.private_app_subnet_ids
  node_security_group_id  = module.network.eks_nodes_security_group_id
  endpoint_public_access  = var.eks_endpoint_public_access
  endpoint_private_access = var.eks_endpoint_private_access
  node_instance_types     = var.eks_node_instance_types
  node_desired_size       = var.eks_node_desired_size
  node_min_size           = var.eks_node_min_size
  node_max_size           = var.eks_node_max_size
  node_disk_size          = var.eks_node_disk_size
  namespace               = "cloudmart-staging"
  irsa_policy_arns = {
    product-service = [module.dynamodb.product_service_policy_arn]
    user-service    = [aws_iam_policy.user_service_rds_secret.arn]
  }
  tags = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.private_data_subnet_ids
  security_group_id     = module.network.rds_security_group_id
  backup_retention_days = 0
  deletion_protection   = false
  skip_final_snapshot   = true
  tags                  = local.common_tags
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  name_prefix = local.name_prefix
  table_name  = "${local.name_prefix}-products"
  tags        = local.common_tags
}

# module "sqs" {}
# module "secrets" {}
