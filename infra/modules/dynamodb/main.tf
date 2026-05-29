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
locals {
  seed_products = {
    "prod-001" = {
      name        = "Wireless Bluetooth Headphones"
      description = "Premium noise-cancelling over-ear headphones with 30-hour battery life"
      price       = "79.99"
      category    = "electronics"
      stock       = "150"
      imageUrl    = "https://example.com/headphones.jpg"
    }
    "prod-002" = {
      name        = "Organic Ceylon Tea (100 bags)"
      description = "Premium hand-picked Ceylon black tea from Nuwara Eliya estates"
      price       = "12.99"
      category    = "food"
      stock       = "500"
      imageUrl    = "https://example.com/tea.jpg"
    }
    "prod-003" = {
      name        = "USB-C Laptop Stand"
      description = "Adjustable aluminium stand with integrated USB-C hub"
      price       = "49.99"
      category    = "electronics"
      stock       = "75"
      imageUrl    = "https://example.com/laptop-stand.jpg"
    }
    "prod-004" = {
      name        = "Handloom Cotton Sarong"
      description = "Traditional Sri Lankan handloom sarong, 100% cotton, machine washable"
      price       = "24.99"
      category    = "clothing"
      stock       = "200"
      imageUrl    = "https://example.com/sarong.jpg"
    }
    "prod-005" = {
      name        = "Mechanical Keyboard (TKL)"
      description = "Tenkeyless mechanical keyboard with Cherry MX Brown switches"
      price       = "89.99"
      category    = "electronics"
      stock       = "60"
      imageUrl    = "https://example.com/keyboard.jpg"
    }
    "prod-006" = {
      name        = "Coconut Oil (Cold Pressed, 500ml)"
      description = "Virgin cold-pressed coconut oil from Southern Province, Sri Lanka"
      price       = "8.99"
      category    = "food"
      stock       = "300"
      imageUrl    = "https://example.com/coconut-oil.jpg"
    }
  }
}

resource "aws_dynamodb_table_item" "seed_products" {
  for_each = var.seed_products ? local.seed_products : {}

  table_name = aws_dynamodb_table.products.name
  hash_key   = aws_dynamodb_table.products.hash_key

  item = jsonencode({
    id          = { S = each.key }
    name        = { S = each.value.name }
    description = { S = each.value.description }
    price       = { N = each.value.price }
    category    = { S = each.value.category }
    stock       = { N = each.value.stock }
    imageUrl    = { S = each.value.imageUrl }
    createdAt   = { S = "2026-05-29T00:00:00Z" }
  })
}

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
