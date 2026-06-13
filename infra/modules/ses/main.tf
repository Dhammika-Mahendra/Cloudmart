resource "aws_ses_email_identity" "sender" {
  email = var.from_email
}

resource "aws_iam_policy" "notification_service" {
  name        = "${var.name_prefix}-notification-service-ses-policy"
  description = "Allow notification-service to send CloudMart emails through SES."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ses:SendEmail",
        "ses:SendRawEmail"
      ]
      Resource = "*"
    }]
  })

  tags = var.tags
}
