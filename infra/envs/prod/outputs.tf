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

output "sqs_queue_url" {
  description = "SQS queue URL for order events."
  value       = module.sqs.queue_url
}

output "ses_from_email" {
  description = "SES sender email identity."
  value       = module.ses.from_email
}

output "waf_web_acl_arn" {
  description = "WAF Web ACL ARN for ALB Ingress."
  value       = module.security.waf_web_acl_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role ARN for AWS Load Balancer Controller."
  value       = aws_iam_role.aws_load_balancer_controller.arn
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

output "monitoring_alerts_topic_arn" {
  description = "SNS topic ARN for monitoring alerts."
  value       = module.monitoring.alerts_topic_arn
}
