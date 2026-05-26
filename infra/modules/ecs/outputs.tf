output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.this.name
}

output "task_execution_role_arn" {
  description = "ECS task execution role ARN."
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "ECS task role ARN."
  value       = aws_iam_role.task.arn
}

output "service_security_group_id" {
  description = "ECS service security group ID."
  value       = aws_security_group.service.id
}

output "log_group_name" {
  description = "CloudWatch log group used by ECS tasks."
  value       = aws_cloudwatch_log_group.this.name
}
