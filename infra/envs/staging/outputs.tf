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

output "dynamodb_products_table_name" {
  description = "Products table used by product-service."
  value       = module.dynamodb.table_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name. Alias kept consistent with prod outputs."
  value       = module.dynamodb.table_name
}

output "rds_secret_name" {
  description = "Secrets Manager secret name used by user-service."
  value       = module.rds.secret_name
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_node_group_name" {
  description = "EKS managed node group name."
  value       = module.eks.node_group_name
}

output "eks_oidc_provider_arn" {
  description = "EKS OIDC provider ARN for IRSA."
  value       = module.eks.oidc_provider_arn
}

output "eks_service_account_role_arns" {
  description = "IRSA role ARNs for Kubernetes service accounts."
  value       = module.eks.service_account_role_arns
}
