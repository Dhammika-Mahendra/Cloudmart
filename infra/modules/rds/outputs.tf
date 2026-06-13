output "db_instance_id" {
  description = "RDS instance identifier."
  value       = aws_db_instance.this.identifier
}

output "db_endpoint" {
  description = "RDS instance connection endpoint (host:port)."
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "RDS instance hostname (without port)."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS instance port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Database name inside the RDS instance."
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Master username for the RDS instance."
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret holding full DB connection details."
  value       = aws_secretsmanager_secret.rds_password.arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret (use in user-service IRSA policy)."
  value       = aws_secretsmanager_secret.rds_password.name
}

output "db_subnet_group_name" {
  description = "Name of the RDS DB subnet group."
  value       = aws_db_subnet_group.this.name
}
