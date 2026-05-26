# GitHub Actions Setup

CloudMart uses GitHub Actions with AWS OIDC. This avoids storing long-lived AWS access keys in GitHub.

## Required GitHub Secret

Create this repository secret:

| Secret | Purpose |
|--------|---------|
| `AWS_ROLE_TO_ASSUME` | ARN of the AWS IAM role trusted by GitHub Actions |

Example value:

```text
arn:aws:iam::<account-id>:role/cloudmart-github-actions
```

## Required AWS IAM Setup

Create an IAM OIDC provider for GitHub:

```text
https://token.actions.githubusercontent.com
```

Then create an IAM role that trusts this repository. The trust policy should restrict access to your GitHub organization/repository and branches.

Example trust policy shape:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<account-id>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:<github-owner>/<repo-name>:*"
        }
      }
    }
  ]
}
```

For the first bootstrap run, the role needs permission to create:

- S3 bucket and bucket settings
- DynamoDB table
- KMS key and alias
- read caller identity through STS

After bootstrap, reduce permissions where possible and use environment-specific roles for staging and production.

## Workflows

### `terraform-checks.yml`

Runs automatically on pull requests and pushes to `main` or `dev-ramosh99` when infrastructure files change.

It performs:

- `terraform fmt -check`
- `terraform init -backend=false`
- `terraform validate`

### `terraform-bootstrap.yml`

Manual workflow for Stage 1. Run this first from the GitHub Actions tab.

Inputs:

- `action`: `plan` or `apply`
- `aws_region`
- `team_id`
- `owner_email`

Use `plan` first. If the output looks correct, rerun with `apply`.

### `terraform-environment.yml`

Manual workflow for staging/prod Terraform environments.

Use this after bootstrap has created the remote state resources. It requires:

- bootstrap S3 bucket name
- bootstrap DynamoDB lock table name
- target environment: `staging` or `prod`
- action: `plan` or `apply`

This workflow is currently ready for the empty environment stacks. As modules are added, it will deploy the VPC, ECR, EKS, databases, queues, and security resources.

### `services-ci.yml`

Runs automatically when service code changes.

It performs:

- Python dependency install and syntax compilation for Flask services
- Node dependency install and Jest test command for Node services
- React production build for frontend
- Docker image build for all five services
- Trivy scan that fails on CRITICAL findings

This workflow does not push to ECR yet. Add image push and Kubernetes deployment after the ECR and EKS Terraform modules are in place.
