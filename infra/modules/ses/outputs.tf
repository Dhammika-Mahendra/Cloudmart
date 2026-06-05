output "from_email" {
  description = "Verified SES sender email."
  value       = aws_ses_email_identity.sender.email
}

output "identity_arn" {
  description = "SES sender identity ARN."
  value       = aws_ses_email_identity.sender.arn
}

output "notification_service_policy_arn" {
  description = "IAM policy ARN for notification-service SES sending."
  value       = aws_iam_policy.notification_service.arn
}
