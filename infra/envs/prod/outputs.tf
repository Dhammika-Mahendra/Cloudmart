output "vpc_id" {
  description = "Production VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Production public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Production private app subnet IDs."
  value       = module.network.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  description = "Production private data subnet IDs."
  value       = module.network.private_data_subnet_ids
}

output "nat_gateway_enabled" {
  description = "Whether NAT Gateway is enabled."
  value       = module.network.nat_gateway_enabled
}

output "ecr_repository_urls" {
  description = "ECR repositories for CloudMart images."
  value       = module.ecr.repository_urls
}

output "ecs_cluster_name" {
  description = "Value for GitHub secret ECS_CLUSTER_NAME."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Value for GitHub secret ECS_SERVICE_NAME."
  value       = module.ecs.service_name
}

output "ecs_task_execution_role_arn" {
  description = "Value for GitHub secret ECS_TASK_EXECUTION_ROLE_ARN."
  value       = module.ecs.task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "Value for GitHub secret ECS_TASK_ROLE_ARN."
  value       = module.ecs.task_role_arn
}

output "ecs_frontend_port" {
  description = "Temporary public frontend port."
  value       = module.ecs.frontend_port
}

# ─────────────────────────────────────────────
# RDS outputs
# ─────────────────────────────────────────────

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint (host:port). Use as DB_HOST in user-service ConfigMap."
  value       = module.rds.db_endpoint
}

output "rds_db_name" {
  description = "Database name inside the RDS instance."
  value       = module.rds.db_name
}

output "rds_secret_arn" {
  description = "Secrets Manager secret ARN holding full DB credentials. Reference in user-service IRSA policy."
  value       = module.rds.secret_arn
}

output "rds_secret_name" {
  description = "Secrets Manager secret name. Pass to External Secrets Operator or Secrets Store CSI."
  value       = module.rds.secret_name
}

# ─────────────────────────────────────────────
# DynamoDB outputs
# ─────────────────────────────────────────────

output "dynamodb_table_name" {
  description = "DynamoDB table name. Set as DYNAMODB_TABLE env var in product-service."
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN."
  value       = module.dynamodb.table_arn
}

output "dynamodb_product_service_policy_arn" {
  description = "IAM policy ARN to attach to the product-service IRSA role."
  value       = module.dynamodb.product_service_policy_arn
}

