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

module "ecs" {
  source = "../../modules/ecs"

  name_prefix               = local.name_prefix
  aws_region                = var.aws_region
  vpc_id                    = module.network.vpc_id
  subnet_ids                = module.network.public_subnet_ids
  allowed_http_cidrs        = var.ecs_allowed_http_cidrs
  frontend_port             = var.ecs_frontend_port
  task_cpu                  = var.ecs_task_cpu
  task_memory               = var.ecs_task_memory
  desired_count             = var.ecs_desired_count
  log_retention_days        = var.ecs_log_retention_days
  enable_container_insights = var.ecs_enable_container_insights
  tags                      = local.common_tags
}

# module "eks" {}
# module "sqs" {}
# module "secrets" {}

# ─────────────────────────────────────────────
# RDS PostgreSQL — user-service data store
# ─────────────────────────────────────────────
module "rds" {
  source = "../../modules/rds"

  name_prefix           = local.name_prefix
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.private_data_subnet_ids
  security_group_id     = module.network.rds_security_group_id
  db_name               = var.rds_db_name
  db_username           = var.rds_db_username
  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  backup_retention_days = var.rds_backup_retention_days
  multi_az              = var.rds_multi_az
  deletion_protection   = var.rds_deletion_protection
  skip_final_snapshot   = var.rds_skip_final_snapshot
  tags                  = local.common_tags
}

# ─────────────────────────────────────────────
# DynamoDB — product-service catalogue
# ─────────────────────────────────────────────
module "dynamodb" {
  source = "../../modules/dynamodb"

  name_prefix            = local.name_prefix
  table_name             = var.dynamodb_table_name
  billing_mode           = var.dynamodb_billing_mode
  point_in_time_recovery = var.dynamodb_pitr_enabled
  tags                   = local.common_tags
}
