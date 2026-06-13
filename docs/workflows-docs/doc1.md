I'll help you understand the use cases for each workflow. Let me first find and examine these workflow files in your repository. 

Searched for files matching `**/*.{yml,yaml}`, 20 matches

Read [](file:///d%3A/academics/L4-S2/cloud%20management/Cloudmart/.github/workflows/terraform-bootstrap.yml)

Read [](file:///d%3A/academics/L4-S2/cloud%20management/Cloudmart/.github/workflows/services-ci.yml#1-1), lines 1 to 100

Read [](file:///d%3A/academics/L4-S2/cloud%20management/Cloudmart/.github/workflows/terraform-destroy-environment.yml#1-1), lines 1 to 100

Read [](file:///d%3A/academics/L4-S2/cloud%20management/Cloudmart/.github/workflows/eks-build-push-deploy.yml#1-1), lines 1 to 100

Read [](file:///d%3A/academics/L4-S2/cloud%20management/Cloudmart/.github/workflows/eks-admin-access.yml#1-1), lines 1 to 80

Read [](file:///d%3A/academics/L4-S2/cloud%20management/Cloudmart/.github/workflows/terraform-checks.yml)

Searched for files matching `**/.github/workflows/*`, 7 matches

Read [](file:///d%3A/academics/L4-S2/cloud%20management/Cloudmart/.github/workflows/terraform-environment.yml#1-1), lines 1 to 100

Perfect! Now I have all the workflow information. Let me save this and provide you with a comprehensive breakdown. 

Created memory file [](file:///c%3A/Users/broco/AppData/Roaming/Code/User/workspaceStorage/85e61b8b728b689452cda425d373d08e/GitHub.copilot-chat/memory-tool/memories/repo/workflows-guide.md)

## Workflow Use Cases Summary

Here's a breakdown of each workflow in your Cloudmart project:

### **Infrastructure Setup & Maintenance**

1. **Terraform Bootstrap** - One-time infrastructure initialization
   - Creates S3 bucket and DynamoDB table for managing Terraform state
   - Must run first before deploying any environments
   - Manual trigger with plan/apply options

2. **Terraform Checks** - Continuous validation
   - Runs automatically on every push/PR to infra
   - Validates Terraform syntax and formatting consistency
   - Catches issues before they're deployed

3. **Terraform Environment** - Deploy AWS infrastructure
   - Provisions actual cloud resources (EKS, RDS, networking, security)
   - Supports staging and prod environments independently
   - Manual trigger with plan/apply options for safety review

4. **Terraform Destroy Environment** - Cleanup & cost control
   - Tears down entire environment to save costs
   - Requires explicit confirmation string to prevent accidents
   - Gracefully scales down Kubernetes deployments first

### **Kubernetes & Access Management**

5. **EKS Admin Access** - Team management
   - Grants kubectl cluster access to new team members
   - Updates the aws-auth ConfigMap in Kubernetes
   - Manual trigger per IAM user

6. **EKS Build Push Deploy** - Container deployment
   - Builds Docker images for all 5 services (frontend + 4 backends)
   - Pushes to AWS ECR registry
   - Deploys Kubernetes manifests to EKS cluster
   - Automatic on push or manual dispatch

### **Application CI**

7. **Services CI** - Code validation & testing
   - Tests Node.js services (order, notification)
   - Compiles Python services (product, user)
   - Builds and validates frontend
   - Scans Docker images for vulnerabilities
   - Runs automatically on PRs/pushes to services

All workflows use OIDC for AWS authentication (no long-lived credentials stored). The typical deployment pipeline is: Code → Tests → Infrastructure → Containers → EKS Deployment.