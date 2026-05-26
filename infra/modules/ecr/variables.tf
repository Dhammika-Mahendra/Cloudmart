variable "repository_prefix" {
  description = "Prefix for ECR repositories."
  type        = string
  default     = "cloudmart"
}

variable "repositories" {
  description = "CloudMart service repository names."
  type        = list(string)
  default = [
    "product-service",
    "order-service",
    "user-service",
    "notification-service",
    "frontend"
  ]
}

variable "images_to_keep" {
  description = "Number of recent images retained per repository."
  type        = number
  default     = 10
}

variable "tags" {
  description = "Common tags to apply to repositories."
  type        = map(string)
  default     = {}
}
