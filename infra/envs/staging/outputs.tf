output "vpc_id" {
  description = "Staging VPC ID."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Staging public subnet IDs."
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Staging private app subnet IDs."
  value       = module.network.private_app_subnet_ids
}

output "private_data_subnet_ids" {
  description = "Staging private data subnet IDs."
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

output "dynamodb_products_table_name" {
  description = "Products table used by product-service."
  value       = module.dynamodb.table_name
}

output "rds_secret_name" {
  description = "Secrets Manager secret name used by user-service."
  value       = module.rds.secret_name
}

output "ecs_frontend_port" {
  description = "Temporary public frontend port."
  value       = module.ecs.frontend_port
}
