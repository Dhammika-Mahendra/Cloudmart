# ─────────────────────────────────────────────
# DynamoDB Table — CloudMart Product Catalogue
# ─────────────────────────────────────────────
resource "aws_dynamodb_table" "products" {
  name         = var.table_name
  billing_mode = var.billing_mode # PAY_PER_REQUEST = on-demand, no provisioned capacity cost
  hash_key     = var.hash_key     # Partition key: "id" (e.g. "prod-001")

  # Schema: only key attributes declared here.
  # Non-key attributes (name, price, category, etc.) are schemaless in DynamoDB.
  attribute {
    name = var.hash_key
    type = "S" # String
  }

  # ── Encryption at rest ─────────────────────
  # AWS-owned CMK is free; use KMS key for tighter control (assignment bonus)
  server_side_encryption {
    enabled = true
  }

  # ── Point-in-time recovery ─────────────────
  # 35-day rolling window; restore to any second within that window
  point_in_time_recovery {
    enabled = var.point_in_time_recovery
  }

  # ── TTL (optional) ─────────────────────────
  dynamic "ttl" {
    for_each = var.enable_ttl ? [1] : []
    content {
      attribute_name = "ttl"
      enabled        = true
    }
  }

  # ── GSI: category-index ────────────────────
  # Allows product-service to query products by category efficiently
  global_secondary_index {
    name            = "category-index"
    hash_key        = "category"
    projection_type = "ALL"
  }

  attribute {
    name = "category"
    type = "S"
  }

  tags = merge(var.tags, {
    Name = var.table_name
  })
}

# ─────────────────────────────────────────────
# IAM Policy — product-service read/write access
# Scoped to THIS table only (assignment: minimal IAM)
# ─────────────────────────────────────────────
resource "aws_iam_policy" "product_service_dynamodb" {
  name        = "${var.name_prefix}-product-service-dynamodb-policy"
  description = "Allow product-service to read/write the CloudMart products DynamoDB table only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ProductTableReadWrite"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTable",
        ]
        Resource = [
          aws_dynamodb_table.products.arn,
          "${aws_dynamodb_table.products.arn}/index/*", # GSI access
        ]
      }
    ]
  })

  tags = var.tags
}
