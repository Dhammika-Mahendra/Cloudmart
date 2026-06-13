variable "name_prefix" {
  description = "Prefix for all resource names (project-environment-team)."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance is placed."
  type        = string
}

variable "subnet_ids" {
  description = "Private data subnet IDs for the RDS subnet group (must span 2+ AZs)."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID that controls inbound access to RDS (from EKS nodes)."
  type        = string
}

variable "db_name" {
  description = "Initial database name to create inside PostgreSQL."
  type        = string
  default     = "cloudmart"
}

variable "db_username" {
  description = "Master username for the RDS instance."
  type        = string
  default     = "cloudmartadmin"
}

variable "instance_class" {
  description = "RDS instance class. db.t3.micro is Free Tier eligible."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "15.18"
}

variable "backup_retention_days" {
  description = "Automated backup retention period in days. Assignment requires 7."
  type        = number
  default     = 7
}

variable "multi_az" {
  description = "Enable Multi-AZ for automatic failover (Recommended for prod)."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "Prevent accidental deletion of the RDS instance."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy. Set true only for dev/testing."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all RDS resources."
  type        = map(string)
  default     = {}
}
