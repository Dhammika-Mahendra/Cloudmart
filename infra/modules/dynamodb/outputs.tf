output "table_name" {
  description = "DynamoDB table name. Pass as DYNAMODB_TABLE env var to product-service."
  value       = aws_dynamodb_table.products.name
}

output "table_arn" {
  description = "DynamoDB table ARN."
  value       = aws_dynamodb_table.products.arn
}

output "table_id" {
  description = "DynamoDB table ID."
  value       = aws_dynamodb_table.products.id
}

output "product_service_policy_arn" {
  description = "IAM policy ARN to attach to the product-service IRSA role."
  value       = aws_iam_policy.product_service_dynamodb.arn
}
