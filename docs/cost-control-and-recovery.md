# CloudMart Cost Control and Recovery

## Recommended Option: Safe Destroy

Use the `Terraform Destroy Environment` GitHub Actions workflow with:

```text
preserve_ecr: true
```

This is the safest cost-reduction option because it removes the high-cost runtime resources while keeping shared container image repositories available for future redeployments.

It removes environment resources such as:

- EKS cluster
- EC2 worker nodes
- ALB and Kubernetes ingress resources
- RDS database
- NAT gateway
- VPC resources
- CloudWatch dashboards and alarms
- Security groups and subnets

It keeps:

- ECR repositories and pushed images
- Terraform S3 state bucket
- Terraform DynamoDB lock table

Keeping ECR is useful because the same repositories are shared by staging and production:

```text
cloudmart/frontend
cloudmart/product-service
cloudmart/user-service
cloudmart/order-service
cloudmart/notification-service
```


## How to Run Safe Destroy

Go to:

```text
GitHub -> Actions -> Terraform Destroy Environment -> Run workflow
```

For staging:

```text
environment: staging
confirmation: destroy-staging
preserve_ecr: true
```

For production:

```text
environment: prod
confirmation: destroy-prod
preserve_ecr: true
```

## Full Remove Option

Full removal means running the destroy workflow with:

```text
preserve_ecr: false
```

This attempts to destroy ECR repositories as well. It is more risky because deleting ECR removes the stored Docker images used by Kubernetes deployments.

Use full removal only when the project is finished or a completely clean AWS account is required.

Potential downside:

- Future deployment must rebuild and push every Docker image again.
- Destroy may fail if ECR repositories still contain images.
- Shared staging/prod image repositories may be removed.

## Recommendation

Use:

```text
preserve_ecr: true
```

This gives the largest billing reduction while keeping recovery simple.

## How to Regain the Environment Later

First, recreate infrastructure:

```text
GitHub -> Actions -> Terraform Environment -> Run workflow
environment: staging or prod
action: apply
```

Then redeploy the application:

```text
GitHub -> Actions -> EKS Build Push Deploy -> Run workflow
environment: staging or prod
```

Branch-based deployment can also be used:

```text
push to stage -> deploy staging
push to main  -> deploy production
```

If ECR was preserved, redeployment is faster and safer because repositories and images remain available. If ECR was deleted, the deployment workflow must recreate repositories and push new images before Kubernetes can run the workloads.

## What Not to Destroy

Do not destroy the Terraform bootstrap stack unless the entire project is finished.

The bootstrap stack contains:

- S3 bucket for Terraform remote state
- DynamoDB table for Terraform state locking
- KMS key for state encryption

Keeping these resources makes future recovery much easier.
