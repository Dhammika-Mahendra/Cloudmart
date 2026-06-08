import {
  to = module.ecr.aws_ecr_repository.this["frontend"]
  id = "cloudmart/frontend"
}

import {
  to = module.ecr.aws_ecr_repository.this["product-service"]
  id = "cloudmart/product-service"
}

import {
  to = module.ecr.aws_ecr_repository.this["user-service"]
  id = "cloudmart/user-service"
}

import {
  to = module.ecr.aws_ecr_repository.this["order-service"]
  id = "cloudmart/order-service"
}

import {
  to = module.ecr.aws_ecr_repository.this["notification-service"]
  id = "cloudmart/notification-service"
}