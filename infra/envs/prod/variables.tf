variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Project tag value."
  type        = string
  default     = "cloudmart"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "prod"
}

variable "team_id" {
  description = "Team or group identifier used in names and tags."
  type        = string
  default     = "group-id"
}

variable "owner_email" {
  description = "Owner email used for cost allocation tags."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the CloudMart VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use."
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Create one NAT Gateway. Required for private subnet internet egress, but has hourly cost."
  type        = bool
  default     = false
}

variable "enable_gateway_endpoints" {
  description = "Create gateway endpoints for S3 and DynamoDB. These do not have hourly endpoint charges."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC REJECT flow logs to CloudWatch. This can create log ingestion/storage cost."
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "CloudWatch retention for VPC Flow Logs when enabled."
  type        = number
  default     = 7
}

variable "bastion_allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH to a future bastion host. Empty keeps SSH closed."
  type        = list(string)
  default     = []
}

variable "eks_cluster_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.30"
}

variable "eks_endpoint_public_access" {
  description = "Allow public access to the EKS API endpoint."
  type        = bool
  default     = true
}

variable "eks_endpoint_private_access" {
  description = "Allow private access to the EKS API endpoint inside the VPC."
  type        = bool
  default     = true
}

variable "eks_node_instance_types" {
  description = "EKS managed node group instance types."
  type        = list(string)
  default     = ["t3.small"]
}

variable "eks_node_desired_size" {
  description = "Desired number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS worker nodes."
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS worker nodes."
  type        = number
  default     = 3
}

variable "eks_node_disk_size" {
  description = "EKS worker node root disk size in GiB."
  type        = number
  default     = 30
}

# ─────────────────────────────────────────────
# RDS PostgreSQL variables
# ─────────────────────────────────────────────

variable "rds_db_name" {
  description = "Database name to create inside the RDS instance."
  type        = string
  default     = "cloudmart"
}

variable "rds_db_username" {
  description = "Master username for the RDS PostgreSQL instance."
  type        = string
  default     = "cloudmartadmin"
}

variable "rds_instance_class" {
  description = "RDS instance class. db.t3.micro is Free Tier eligible."
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS in GB."
  type        = number
  default     = 20
}

variable "rds_backup_retention_days" {
  description = "Automated backup retention in days. Assignment requires 7."
  type        = number
  default     = 7
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ for RDS automatic failover (Recommended [R])."
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "Prevent accidental RDS deletion."
  type        = bool
  default     = true
}

variable "rds_skip_final_snapshot" {
  description = "Skip final snapshot on destroy. Set true only for dev/testing."
  type        = bool
  default     = false
}

# ─────────────────────────────────────────────
# DynamoDB variables
# ─────────────────────────────────────────────

variable "dynamodb_table_name" {
  description = "DynamoDB table name for the product catalogue."
  type        = string
  default     = "cloudmart-products"
}

variable "dynamodb_billing_mode" {
  description = "DynamoDB billing mode. PAY_PER_REQUEST = on-demand (no capacity planning)."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_pitr_enabled" {
  description = "Enable DynamoDB point-in-time recovery (35-day rolling backup window)."
  type        = bool
  default     = true
}
