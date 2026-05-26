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

variable "ecs_allowed_http_cidrs" {
  description = "CIDR blocks allowed to access the temporary ECS frontend."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ecs_frontend_port" {
  description = "Temporary public frontend port for ECS before a load balancer is added."
  type        = number
  default     = 8080
}

variable "ecs_task_cpu" {
  description = "Fargate CPU units for the temporary all-in-one CloudMart task."
  type        = string
  default     = "1024"
}

variable "ecs_task_memory" {
  description = "Fargate memory for the temporary all-in-one CloudMart task."
  type        = string
  default     = "2048"
}

variable "ecs_desired_count" {
  description = "Initial ECS task count. Keep 0 until GitHub Actions deploys images."
  type        = number
  default     = 0
}

variable "ecs_log_retention_days" {
  description = "CloudWatch retention period for ECS logs."
  type        = number
  default     = 7
}

variable "ecs_enable_container_insights" {
  description = "Enable ECS Container Insights. Keep false for lower cost."
  type        = bool
  default     = false
}
