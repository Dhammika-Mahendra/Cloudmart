variable "name_prefix" {
  description = "Prefix for all resource names (project-environment-team)."
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name for the product catalogue."
  type        = string
  default     = "cloudmart-products"
}

variable "billing_mode" {
  description = "DynamoDB billing mode. PAY_PER_REQUEST = on-demand (no capacity planning, Free Tier eligible)."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "hash_key" {
  description = "Partition key attribute name."
  type        = string
  default     = "id"
}

variable "enable_ttl" {
  description = "Enable TTL on a 'ttl' attribute (useful for session/cache records)."
  type        = bool
  default     = false
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB (35-day rolling backup window)."
  type        = bool
  default     = true
}

variable "seed_products" {
  description = "Seed the product catalogue with demo products."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all DynamoDB resources."
  type        = map(string)
  default     = {}
}
