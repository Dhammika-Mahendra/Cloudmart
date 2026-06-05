variable "name_prefix" {
  description = "Name prefix for SQS resources."
  type        = string
}

variable "message_retention_seconds" {
  description = "How long order events stay in the queue."
  type        = number
  default     = 345600
}

variable "visibility_timeout_seconds" {
  description = "Message visibility timeout for notification-service processing."
  type        = number
  default     = 30
}

variable "max_receive_count" {
  description = "Receive attempts before moving a message to the DLQ."
  type        = number
  default     = 5
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
