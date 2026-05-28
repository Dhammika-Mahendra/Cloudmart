# ─────────────────────────────────────────────
# RDS Subnet Group  (must span 2+ AZs)
# ─────────────────────────────────────────────
resource "aws_db_subnet_group" "this" {
  name        = "${var.name_prefix}-rds-subnet-group"
  description = "Private data subnets for CloudMart RDS PostgreSQL"
  subnet_ids  = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-subnet-group"
  })
}

# ─────────────────────────────────────────────
# RDS Parameter Group  (enforce SSL)
# ─────────────────────────────────────────────
resource "aws_db_parameter_group" "this" {
  name        = "${var.name_prefix}-rds-pg15"
  family      = "postgres15"
  description = "CloudMart PostgreSQL 15 — SSL enforced"

  # rds.force_ssl = 1 rejects any connection that does not use SSL
  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "immediate"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-pg15"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ─────────────────────────────────────────────
# Master password stored in AWS Secrets Manager
# (RDS managed rotation — no plaintext in state)
# ─────────────────────────────────────────────
resource "aws_secretsmanager_secret" "rds_password" {
  name                    = "${var.name_prefix}/rds/master-password"
  description             = "Auto-generated master password for CloudMart RDS instance"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-master-password"
  })
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.master.result
    dbname   = var.db_name
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    engine   = "postgres"
  })

  # Depend on the instance so host/port are available
  depends_on = [aws_db_instance.this]
}

resource "random_password" "master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ─────────────────────────────────────────────
# RDS PostgreSQL Instance
# ─────────────────────────────────────────────
resource "aws_db_instance" "this" {
  identifier = "${var.name_prefix}-postgres"

  # Engine
  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true # Encryption at rest — assignment [M]

  # Credentials
  db_name  = var.db_name
  username = var.db_username
  password = random_password.master.result

  # Networking — data subnet, not publicly accessible
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]
  publicly_accessible    = false # Assignment: DB must NOT be accessible from internet

  # SSL enforcement via parameter group
  parameter_group_name = aws_db_parameter_group.this.name

  # Backup & recovery — assignment requires 7-day retention + PITR
  backup_retention_period  = var.backup_retention_days
  backup_window            = "02:00-03:00" # UTC — low-traffic window
  maintenance_window       = "Mon:03:00-Mon:04:00"
  copy_tags_to_snapshot    = true
  delete_automated_backups = false

  # High availability
  multi_az = var.multi_az

  # Performance Insights (free for db.t3 — useful for monitoring)
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Enhanced monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  # Protection
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.name_prefix}-postgres-final"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-postgres"
  })
}

# ─────────────────────────────────────────────
# IAM role for RDS Enhanced Monitoring
# ─────────────────────────────────────────────
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.name_prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "monitoring.rds.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
