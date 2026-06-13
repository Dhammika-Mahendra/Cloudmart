output "guardduty_detector_id" {
  description = "GuardDuty detector ID."
  value       = try(aws_guardduty_detector.this[1].id, null)
}

output "waf_web_acl_arn" {
  description = "WAFv2 Web ACL ARN for ALB Ingress annotation."
  value       = try(aws_wafv2_web_acl.this[1].arn, null)
}
