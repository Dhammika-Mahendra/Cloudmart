resource "aws_guardduty_detector" "this"  {
  count  = var.enable_guardduty ? 1 : 0
  enable = true

  tags = merge(var.tags,  {
    Name = "${var.name_prefix}-guardduty"
   })
}

resource "aws_wafv2_web_acl" "this" {
  count       = var.enable_waf ? 1 : 0
  name        = "${var.name_prefix}-web-acl"
  description = "CloudMart baseline WAF for ALB Ingress"
  scope       = "REGIONAL"

  default_action  {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement  {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
       }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-common-rules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-web-acl"
    sampled_requests_enabled   = true
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-web-acl"
  })
}
