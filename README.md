# CloudMart — Starter Code

**IS 4630 Cloud Infrastructure Management | University of Moratuwa**

CloudMart is a microservices-based e-commerce platform used as the group assignment project for IS 4630. This repository contains fully working starter code for all five services.

## Architecture

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   Frontend   │────▶│  product-service │     │   user-service   │
│  (React/Nginx│────▶│  (Flask :8001)   │     │  (Flask :8003)   │
│   :80/443)   │────▶│                  │     │  JWT + bcrypt    │
│              │     └──────────────────┘     └──────────────────┘
│              │────▶┌──────────────────┐
│              │     │  order-service   │────▶ product-service
└──────────────┘     │  (Express :8002) │        (stock check)
                     │                  │
                     └───────┬──────────┘
                             │ publishes
                             ▼
                     ┌──────────────────┐
                     │  Message Queue   │
                     │  (in-memory/SQS/ │
                     │   Pub-Sub/SB)    │
                     └───────┬──────────┘
                             │ consumes
                             ▼
                     ┌──────────────────┐
                     │ notification-svc │
                     │  (Node.js :8004) │
                     │  sends emails    │
                     └──────────────────┘
```

## Services

| Service | Port | Language | Description |
|---------|------|----------|-------------|
| **product-service** | 8001 | Python/Flask | Product catalogue CRUD, search, categories, stock management |
| **order-service** | 8002 | Node.js/Express | Order creation, status management, publishes events to queue |
| **user-service** | 8003 | Python/Flask | User registration, JWT authentication, profile management |
| **notification-service** | 8004 | Node.js | Consumes order events, sends email notifications |
| **frontend** | 80 | React/Nginx | SPA with product browsing, cart, checkout, order history |

## Quick Start (Local Development)

### Prerequisites

- Docker Desktop installed and running
- Git

### Run with Docker Compose

```bash
git clone <your-repo-url>
cd cloudmart-starter
docker compose up --build
```

Open http://localhost:3000 in your browser.

**Demo credentials:** `alice@cloudmart.example` / `password123`

### Test individual services

```bash
# Health checks
curl http://localhost:8001/health
curl http://localhost:8002/health
curl http://localhost:8003/health
curl http://localhost:8004/health

# List products
curl http://localhost:8001/products

# Search products
curl "http://localhost:8001/products?search=headphone"

# Filter by category
curl "http://localhost:8001/products?category=electronics"

# Register a new user
curl -X POST http://localhost:8003/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:8003/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@cloudmart.example","password":"password123"}'

# Create an order (use the token from login response)
curl -X POST http://localhost:8002/orders \
  -H "Content-Type: application/json" \
  -d '{"userId":"user-001","items":[{"productId":"prod-001","quantity":1}]}'

# Check notification log
curl http://localhost:8004/notifications
```

## Cloud Adapter Pattern

All services use an **adapter pattern** for cloud backends. By default, they run with in-memory data stores (no cloud credentials needed). To connect to cloud-managed services, set the appropriate environment variables:

### Product Service

| Variable | Values | Description |
|----------|--------|-------------|
| `STORE_BACKEND` | `memory` (default), `dynamodb`, `firestore`, `cosmosdb` | Data store backend |
| `DYNAMODB_TABLE` | Table name | Required when STORE_BACKEND=dynamodb |
| `FIRESTORE_COLLECTION` | Collection name | Required when STORE_BACKEND=firestore |

### Order Service

| Variable | Values | Description |
|----------|--------|-------------|
| `QUEUE_BACKEND` | `memory` (default), `sqs`, `pubsub`, `servicebus` | Message queue backend |
| `SQS_QUEUE_URL` | Queue URL | Required when QUEUE_BACKEND=sqs |
| `PUBSUB_TOPIC` | Topic name | Required when QUEUE_BACKEND=pubsub |

### User Service

| Variable | Values | Description |
|----------|--------|-------------|
| `DB_BACKEND` | `memory` (default), `postgres` | Database backend |
| `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` | Connection details | Required when DB_BACKEND=postgres |
| `JWT_SECRET` | Secret string | **Change this in production!** |

### Notification Service

| Variable | Values | Description |
|----------|--------|-------------|
| `QUEUE_BACKEND` | `memory` (default), `sqs`, `pubsub`, `servicebus` | Queue to poll for events |
| `EMAIL_BACKEND` | `console` (default), `ses`, `sendgrid` | Email sending backend |
| `FROM_EMAIL` | Email address | Sender email for cloud backends |

## Assignment Tasks

Your group needs to:

1. **Containerise** — The Dockerfiles are provided as best-practice examples. Review and understand them.
2. **Push to registry** — Push all 5 images to your cloud provider's container registry.
3. **Implement cloud adapters** — Replace the in-memory stores with real cloud databases and queues.
4. **Deploy to Kubernetes** — Create Deployments, Services, Ingress, ConfigMaps, and Secrets.
5. **Secure** — Add NetworkPolicy, workload identity, WAF, and threat detection.
6. **Build CI/CD** — Automate test → build → scan → push → deploy.
7. **Monitor** — Set up dashboards, logging, and alerts.
8. **Optimise costs** — Tag resources, analyse spend, right-size instances.

See the full assignment brief for detailed requirements.

## Project Structure

```
cloudmart-starter/
├── docker-compose.yml          # Local development orchestration
├── README.md                   # This file
├── services/
│   ├── product-service/
│   │   ├── app.py              # Flask app with in-memory + cloud adapters
│   │   ├── requirements.txt
│   │   ├── Dockerfile          # Multi-stage, non-root, healthcheck
│   │   └── .dockerignore
│   ├── order-service/
│   │   ├── src/index.js        # Express app with queue adapters
│   │   ├── package.json
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   ├── user-service/
│   │   ├── app.py              # Flask app with JWT + bcrypt
│   │   ├── requirements.txt
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   ├── notification-service/
│   │   ├── src/index.js        # Queue consumer + email sender
│   │   ├── package.json
│   │   ├── Dockerfile
│   │   └── .dockerignore
│   └── frontend/
│       ├── src/                # React SPA source
│       ├── public/
│       ├── nginx.conf          # Reverse proxy config
│       ├── package.json
│       ├── Dockerfile          # Multi-stage: npm build → nginx
│       └── .dockerignore
├── k8s/                        # Kubernetes manifest templates
│   ├── namespace.yaml
│   ├── product-service.yaml
│   ├── order-service.yaml
│   ├── user-service.yaml
│   ├── notification-service.yaml
│   ├── frontend.yaml
│   ├── configmap.yaml
│   └── network-policy.yaml
└── docs/adr/                   # Architecture Decision Records go here
```

## Cloud Provider

**Chosen provider:** AWS

AWS service mapping for this project:

| Requirement | AWS Service |
|-------------|-------------|
| Managed Kubernetes | Amazon EKS |
| Container registry | Amazon ECR |
| Relational database | Amazon RDS for PostgreSQL |
| NoSQL database | Amazon DynamoDB |
| Message queue | Amazon SQS |
| Email service | Amazon SES |
| Load balancer / Ingress | AWS Load Balancer Controller + ALB |
| Monitoring and logs | Amazon CloudWatch |
| Threat detection | Amazon GuardDuty |
| Object storage | Amazon S3 |
| Key management | AWS KMS |
| Secret management | AWS Secrets Manager |

## AWS Deployment Roadmap

The repository is prepared for staged AWS deployment:

1. Stage 0: repository structure, service folders, `infra/`, `k8s/`, and `docs/adr/`.
2. Stage 1: Terraform backend bootstrap using S3, DynamoDB state locking, and KMS encryption.
3. Stage 2: VPC, public/private/data subnets, route tables, NAT gateway, VPC endpoints, and flow logs.
4. Stage 3: ECR repositories for all five services.
5. Stage 4: RDS PostgreSQL, DynamoDB, SQS, SES, Secrets Manager, and KMS.
6. Stage 5: EKS cluster, node groups, IRSA, cluster add-ons, and AWS Load Balancer Controller.
7. Stage 6: Kubernetes Deployments, Services, Ingress, ConfigMaps, Secrets, HPA, PDB, and NetworkPolicies.
8. Stage 7: GitHub Actions CI/CD for test, build, Trivy scan, push to ECR, and deploy to staging/prod.

Start with:

```bash
cd infra/bootstrap
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Copy `infra/bootstrap/terraform.tfvars.example` to `infra/bootstrap/terraform.tfvars` first and update `team_id` and `owner_email`.

GitHub Actions setup notes are available in `docs/github-actions-setup.md`.
EKS deployment is handled by `.github/workflows/eks-build-push-deploy.yml` after the Terraform environment stack has been applied.
The full AWS setup and progress runbook is available in `docs/cloudmart-aws-runbook.md`.

For low-cost Stage 2 deployment, NAT Gateway and VPC Flow Logs are disabled by default. Enable them only when you need private subnet internet egress or flow-log evidence for the report.

## Team Members

| Name | Student ID | Responsibilities |
|------|-----------|-----------------|
| | | |
| | | |
| | | |
| | | |
| | | |

## AI Tool Disclosure

_[If your group used GitHub Copilot, ChatGPT, Claude, or any AI assistant, disclose here: which tools, for which tasks, and what review process you applied.]_

---

*IS 4630 Cloud Infrastructure Management | University of Moratuwa | Academic Year 2025/2026*
