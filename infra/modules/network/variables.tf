variable "name_prefix" {
  description = "Prefix used for AWS resource names."
  type        = string
}

variable "aws_region" {
  description = "AWS region where resources are created."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2
    error_message = "At least two availability zones are required."
  }
}

variable "enable_nat_gateway" {
  description = "Create a single NAT Gateway for private app subnet egress. This has hourly and data processing cost."
  type        = bool
  default     = false
}

variable "enable_gateway_endpoints" {
  description = "Create free gateway VPC endpoints for S3 and DynamoDB."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC REJECT flow logs to CloudWatch. This can create log ingestion/storage cost."
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "Retention period for VPC Flow Logs when enabled."
  type        = number
  default     = 7
}

variable "bastion_allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH to the optional bastion security group. Empty list keeps SSH closed."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}
