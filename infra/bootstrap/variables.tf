variable "aws_region" {
  description = "AWS region used for the Terraform backend resources."
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Project tag value."
  type        = string
  default     = "cloudmart"
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
