# CloudMart AWS Infrastructure

This directory is organized in stages so the AWS foundation can be created safely before deploying CloudMart on EKS.

## Stage 1: Terraform Remote State Bootstrap

Create the shared Terraform backend resources first:

```bash
cd infra/bootstrap
terraform init
terraform plan -var-file=terraform.tfvars.example
terraform apply -var-file=terraform.tfvars.example
```

For real use, copy `terraform.tfvars.example` to `terraform.tfvars` and adjust the values. The generated S3 bucket, DynamoDB lock table, and KMS key are then used by `infra/envs/staging` and `infra/envs/prod`.

## Stage 2+: Environment Deployments

After bootstrap succeeds, update each environment backend file with the real bucket/table names, then run:

```bash
cd infra/envs/staging
terraform init
terraform plan
```

Production follows the same pattern from `infra/envs/prod`.

## Stage 2: Low-Cost Network

The network module creates:

- VPC with DNS enabled
- 2 Availability Zones
- public, private app, and private data subnets in each AZ
- Internet Gateway and public route table
- private app and private data route tables
- security groups for ALB, EKS nodes, RDS, and bastion
- free gateway VPC endpoints for S3 and DynamoDB

By default, EKS environments enable NAT Gateway because private worker nodes need outbound access to pull images and call AWS APIs:

```hcl
enable_nat_gateway = true
enable_flow_logs   = false
```

NAT Gateway has an hourly charge. Later, interface VPC endpoints for ECR, STS, CloudWatch Logs, and Secrets Manager can reduce NAT dependency. Flow Logs are useful for assignment evidence, but CloudWatch log ingestion/storage can cost money. Turn them on only when needed:

```hcl
enable_flow_logs   = true
```

Gateway endpoints for S3 and DynamoDB stay enabled because they avoid NAT traffic and do not have hourly endpoint charges.

## EKS Environment Deployment

The staging and production environments create:

- five ECR repositories with scan-on-push and lifecycle cleanup
- an EKS cluster
- an EKS managed node group in private application subnets
- EKS OIDC provider for IAM Roles for Service Accounts
- IRSA roles for product-service and user-service
- RDS PostgreSQL for user-service
- DynamoDB for product-service

Private EKS worker nodes need outbound access for image pulls and AWS APIs. The examples enable NAT Gateway for that path. Later, interface VPC endpoints for ECR, STS, CloudWatch Logs, and Secrets Manager can reduce NAT dependency.

After applying staging, run:

```bash
terraform output
```

The `eks-build-push-deploy.yml` workflow reads the EKS, ECR, DynamoDB, RDS, and IRSA values from Terraform remote state.

To initialize staging with the bootstrap backend:

```bash
cd infra/envs/staging
terraform init \
  -backend-config="bucket=cloudmart-13-tfstate-804431973197" \
  -backend-config="key=staging/terraform.tfstate" \
  -backend-config="region=ap-south-1" \
  -backend-config="dynamodb_table=cloudmart-13-terraform-locks" \
  -backend-config="encrypt=true"
terraform plan -var-file=terraform.tfvars
```

Use the bucket and table names from your own bootstrap outputs if they differ.

## Planned Modules

- `modules/network`: VPC, subnets, route tables, optional NAT, endpoints, optional flow logs
- `modules/ecr`: one ECR repository per service
- `modules/eks`: EKS cluster, node groups, OIDC, add-ons
- `modules/rds`: PostgreSQL for user-service
- `modules/dynamodb`: product catalogue table
- `modules/sqs`: order events queue
- `modules/ses`: email identity setup
- `modules/secrets`: Secrets Manager entries and KMS wiring
- `modules/monitoring`: CloudWatch dashboards, alarms, Container Insights
- `modules/security`: GuardDuty, WAF, CloudTrail, security guardrails
