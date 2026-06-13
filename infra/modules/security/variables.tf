variable "name_prefix" {
  description = "Name prefix for security resources."
  type        = string
}

variable "enable_guardduty" {
  description = "Enable Amazon GuardDuty."
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Create a regional AWS WAF Web ACL."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
