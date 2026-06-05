output "queue_url" {
  description = "Order events queue URL."
  value       = aws_sqs_queue.orders.url
}

output "queue_arn" {
  description = "Order events queue ARN."
  value       = aws_sqs_queue.orders.arn
}

output "dlq_url" {
  description = "Dead-letter queue URL."
  value       = aws_sqs_queue.dlq.url
}

output "order_service_policy_arn" {
  description = "IAM policy ARN for order-service SQS publishing."
  value       = aws_iam_policy.order_service.arn
}

output "notification_service_policy_arn" {
  description = "IAM policy ARN for notification-service SQS consuming."
  value       = aws_iam_policy.notification_service.arn
}
