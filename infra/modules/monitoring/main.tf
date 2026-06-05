resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-alerts"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alerts"
  })
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_dashboard" "cloudmart" {
  dashboard_name = "${var.name_prefix}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          region = var.aws_region
          title  = "EKS node CPU utilization"
          metrics = [
            ["AWS/EC2", "CPUUtilization", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          region = var.aws_region
          title  = "Product service error rate custom metric"
          metrics = [
            ["CloudMart", "ProductServiceErrorRatePercent", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "product_error_rate" {
  alarm_name          = "${var.name_prefix}-product-service-error-rate"
  alarm_description   = "Product service error rate above 5 percent for 5 minutes."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ProductServiceErrorRatePercent"
  namespace           = "CloudMart"
  period              = 300
  statistic           = "Average"
  threshold           = 5
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = var.cluster_name
  }

  tags = var.tags
}
