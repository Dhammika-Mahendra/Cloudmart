variable "name_prefix" {
  description = "Name prefix for monitoring resources."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "alert_email" {
  description = "Email address for CloudWatch alarm notifications."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
