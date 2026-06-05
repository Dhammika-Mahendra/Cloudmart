output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded EKS cluster CA data."
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "node_group_name" {
  description = "Managed node group name."
  value       = aws_eks_node_group.this.node_group_name
}

output "node_role_arn" {
  description = "EKS node IAM role ARN."
  value       = aws_iam_role.nodes.arn
}

output "oidc_provider_arn" {
  description = "EKS OIDC provider ARN for IRSA."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "service_account_role_arns" {
  description = "IRSA role ARNs keyed by service account name."
  value       = { for name, role in aws_iam_role.service_account : name => role.arn }
}
