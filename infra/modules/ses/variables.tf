variable "name_prefix" {
  description = "Name prefix for SES resources."
  type        = string
}

variable "from_email" {
  description = "Email identity used as the CloudMart notification sender."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
