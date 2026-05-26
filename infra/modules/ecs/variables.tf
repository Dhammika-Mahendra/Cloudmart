variable "name_prefix" {
  description = "Prefix used for ECS resource names."
  type        = string
}

variable "aws_region" {
  description = "AWS region where ECS resources are created."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the ECS service."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the temporary ECS Fargate service."
  type        = list(string)
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed to access the frontend on port 80."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "task_cpu" {
  description = "Fargate task CPU units."
  type        = string
  default     = "1024"
}

variable "task_memory" {
  description = "Fargate task memory in MiB."
  type        = string
  default     = "2048"
}

variable "desired_count" {
  description = "Initial ECS service task count. Keep 0 for no runtime cost until GitHub Actions deploys."
  type        = number
  default     = 0
}

variable "log_retention_days" {
  description = "CloudWatch log retention for ECS service logs."
  type        = number
  default     = 7
}

variable "enable_container_insights" {
  description = "Enable ECS Container Insights. Keep false for lower cost."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
  default     = {}
}
