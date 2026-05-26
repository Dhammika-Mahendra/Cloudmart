# ECS Deployment Setup

This is a temporary AWS-native deployment path before EKS and the AWS Load Balancer Controller are added.

## Flow

```text
GitHub push/manual run
-> build five container images
-> scan with Trivy
-> push to Amazon ECR
-> optionally register a new ECS task definition
-> update ECS service
```

This still uses container images, but deployment is handled by Amazon ECS instead of a manually managed Docker host.

## Important Assignment Note

ECS does not satisfy the final "managed Kubernetes" requirement. Use this for an early low-cost AWS deployment milestone, then move to EKS for the final submission.

## Required GitHub Secrets

For build and push:

| Secret | Purpose |
|--------|---------|
| `AWS_ROLE_TO_ASSUME` | AWS IAM role ARN trusted by GitHub OIDC |

For ECS deployment:

| Secret | Purpose |
|--------|---------|
| `ECS_CLUSTER_NAME` | ECS cluster name |
| `ECS_SERVICE_NAME` | ECS service name |
| `ECS_TASK_EXECUTION_ROLE_ARN` | IAM role used by ECS to pull images and write logs |
| `ECS_TASK_ROLE_ARN` | IAM role used by the app containers |
| `JWT_SECRET` | Runtime JWT secret for user-service |

After applying `infra/envs/staging`, get the ECS values from:

```bash
terraform output
```

Use these outputs as GitHub secret values:

```text
ecs_cluster_name              -> ECS_CLUSTER_NAME
ecs_service_name              -> ECS_SERVICE_NAME
ecs_task_execution_role_arn   -> ECS_TASK_EXECUTION_ROLE_ARN
ecs_task_role_arn             -> ECS_TASK_ROLE_ARN
```

## AWS Permissions Needed

The GitHub Actions IAM role needs ECR permissions:

- `ecr:GetAuthorizationToken`
- `ecr:DescribeRepositories`
- `ecr:CreateRepository`
- `ecr:PutImage`
- `ecr:InitiateLayerUpload`
- `ecr:UploadLayerPart`
- `ecr:CompleteLayerUpload`
- `ecr:BatchCheckLayerAvailability`
- `ecr:BatchGetImage`

For ECS deployment it also needs:

- `ecs:RegisterTaskDefinition`
- `ecs:UpdateService`
- `ecs:DescribeServices`
- `ecs:DescribeTaskDefinition`
- `logs:CreateLogGroup`
- `logs:DescribeLogGroups`
- `iam:PassRole` for the ECS task execution role and task role

## Low-Cost Behavior

Terraform creates the ECS service with:

```hcl
ecs_desired_count = 0
```

That means the ECS service exists, but no Fargate task is running yet. This avoids runtime compute cost until GitHub Actions deploys the app.

When `deploy_to_ecs` is `true`, GitHub Actions updates the service to:

```text
desired-count 1
```

To stop the running app and reduce cost after testing:

```bash
aws ecs update-service \
  --cluster <ECS_CLUSTER_NAME> \
  --service <ECS_SERVICE_NAME> \
  --desired-count 0 \
  --region ap-south-1
```

## Runtime Shape

The starter ECS task definition runs all five containers in one Fargate task:

- frontend: public container on port `80`
- product-service: localhost `8001`
- order-service: localhost `8002`
- user-service: localhost `8003`
- notification-service: localhost `8004`

Because containers in the same Fargate task share the task network namespace, the ECS frontend build uses `nginx.ecs.conf` and proxies API calls to `127.0.0.1`.

## Run It

Open GitHub Actions and run:

```text
ECS Build Push Deploy
```

Choose:

```text
environment: staging
deploy_to_ecs: true
```

If you only want to build and push images to ECR, keep:

```text
deploy_to_ecs: false
```

## Open The App

Because this temporary setup has no load balancer, open the public IP of the running ECS task.

Find it with:

```bash
aws ecs list-tasks \
  --cluster <ECS_CLUSTER_NAME> \
  --service-name <ECS_SERVICE_NAME> \
  --region ap-south-1
```

Then describe the task and network interface:

```bash
aws ecs describe-tasks \
  --cluster <ECS_CLUSTER_NAME> \
  --tasks <TASK_ARN> \
  --region ap-south-1
```

Use the `networkInterfaceId` from the task attachment:

```bash
aws ec2 describe-network-interfaces \
  --network-interface-ids <ENI_ID> \
  --query "NetworkInterfaces[0].Association.PublicIp" \
  --output text \
  --region ap-south-1
```

Open:

```text
http://<PUBLIC_IP>
```
