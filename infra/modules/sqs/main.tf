resource "aws_sqs_queue" "dlq" {
  name                      = "${var.name_prefix}-order-events-dlq"
  message_retention_seconds = 1209600

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-order-events-dlq"
  })
}

resource "aws_sqs_queue" "orders" {
  name                       = "${var.name_prefix}-order-events"
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-order-events"
  })
}

resource "aws_iam_policy" "order_service" {
  name        = "${var.name_prefix}-order-service-sqs-policy"
  description = "Allow order-service to publish CloudMart order events."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:SendMessage"
      ]
      Resource = aws_sqs_queue.orders.arn
    }]
  })

  tags = var.tags
}

resource "aws_iam_policy" "notification_service" {
  name        = "${var.name_prefix}-notification-service-sqs-policy"
  description = "Allow notification-service to consume CloudMart order events."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ChangeMessageVisibility",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:GetQueueUrl",
        "sqs:ReceiveMessage"
      ]
      Resource = aws_sqs_queue.orders.arn
    }]
  })

  tags = var.tags
}
