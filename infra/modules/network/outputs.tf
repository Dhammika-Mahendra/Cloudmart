output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability zones used by the network."
  value       = local.azs
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = values(aws_subnet.public)[*].id
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs."
  value       = values(aws_subnet.private_app)[*].id
}

output "private_data_subnet_ids" {
  description = "Private data subnet IDs."
  value       = values(aws_subnet.private_data)[*].id
}

output "alb_security_group_id" {
  description = "Security group ID for the future ALB."
  value       = aws_security_group.alb.id
}

output "eks_nodes_security_group_id" {
  description = "Security group ID for future EKS worker nodes."
  value       = aws_security_group.eks_nodes.id
}

output "rds_security_group_id" {
  description = "Security group ID for future RDS PostgreSQL."
  value       = aws_security_group.rds.id
}

output "bastion_security_group_id" {
  description = "Security group ID for an optional bastion host."
  value       = aws_security_group.bastion.id
}

output "nat_gateway_enabled" {
  description = "Whether a NAT Gateway was created."
  value       = var.enable_nat_gateway
}

output "flow_logs_enabled" {
  description = "Whether VPC Flow Logs were enabled."
  value       = var.enable_flow_logs
}
