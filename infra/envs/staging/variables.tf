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
  default     = "staging"
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
  description = "Create one NAT Gateway. Required for private EKS worker nodes unless ECR/STS/Logs/Secrets Manager interface endpoints are added."
  type        = bool
  default     = true
}

variable "enable_gateway_endpoints" {
  description = "Create gateway endpoints for S3 and DynamoDB. These do not have hourly endpoint charges."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC REJECT flow logs to CloudWatch. Keep false for lowest cost."
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

variable "rds_backup_retention_days" {
  description = "Automated backup retention in days. Use 0 only when the AWS account Free Tier restriction blocks backups."
  type        = number
  default     = 0
}

variable "ses_from_email" {
  description = "SES sender email identity for CloudMart notifications."
  type        = string
  default     = "noreply@cloudmart.example"
}

variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications."
  type        = string
  default     = "yasiram447@gmail.com"
}

variable "enable_guardduty" {
  description = "Enable GuardDuty threat detection."
  type        = bool
  default     = false
}

variable "enable_waf" {
  description = "Create WAF for ALB Ingress."
  type        = bool
  default     = true
}
