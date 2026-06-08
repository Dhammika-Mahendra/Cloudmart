# ADR-001: Selection of AWS EC2 t3.small for Kubernetes Worker Nodes

## Status

Accepted

## Context

The CloudMart platform consists of five lightweight microservices:

* Frontend
* Product Service
* Order Service
* User Service
* Notification Service

The application relies heavily on managed cloud services (RDS PostgreSQL, DynamoDB, SQS, and SES), reducing compute requirements on Kubernetes worker nodes. As this is an academic assignment, the solution should meet functional requirements while minimizing infrastructure costs.

## Decision

Use **AWS EC2 t3.small** instances for Kubernetes worker nodes in the EKS cluster.

### Instance Comparison (Mumbai Region)

| Instance Type | vCPU | Memory | Hourly Cost | Monthly Cost* |
| ------------- | ---- | ------ | ----------- | ------------- |
| t3.small      | 2    | 2 GiB  | $0.0224     | ~$16.35       |
| t3.medium     | 2    | 4 GiB  | $0.0448     | ~$32.70       |
| t3.large      | 2    | 8 GiB  | $0.0896     | ~$65.41       |

*Monthly cost calculated using 730 hours/month.

## Rationale

### Why t3.small is Sufficient

* All five services are lightweight containerized applications.
* Database, messaging, and email workloads are handled by managed services rather than Kubernetes nodes.
* Resource requests and limits are configured for all pods.
* HPA is enabled for Product Service and Order Service.
* A cluster of **2–3 t3.small nodes** provides adequate CPU and memory capacity for the expected assignment workload.
* Burstable T3 instances can temporarily utilize additional CPU resources during traffic spikes.

## Cost Analysis

| Cluster Configuration | Estimated Monthly Cost |
| --------------------- | ---------------------- |
| 2 × t3.small          | ~$32.70                |
| 3 × t3.small          | ~$49.05                |
| 2 × t3.medium         | ~$65.40                |
| 3 × t3.medium         | ~$98.10                |
| 2 × t3.large          | ~$130.82               |

Using **3 × t3.small** worker nodes costs approximately the same as **1.5 t3.medium nodes**, while still providing sufficient capacity and high availability for the project.

## Alternatives Considered

### t3.medium

**Pros**

* Double the memory (4 GiB).
* More headroom for future scaling.

**Cons**

* Approximately 2× the cost of t3.small.
* Additional memory is unlikely to be utilized by the project workload.

### t3.large

**Pros**

* 8 GiB memory capacity.
* Better suited for large-scale production workloads.

**Cons**

* Approximately 4× the cost of t3.small.
* Significantly overprovisioned for an academic microservices deployment.

## Consequences

### Positive

* Lowest infrastructure cost.
* Meets performance requirements for all five services.
* Supports required replicas, monitoring, and autoscaling.
* Aligns with the project's free-tier/minimal-cost objective.

### Negative

* Limited capacity for production-scale traffic.
* Instance upgrades may be required if workload demand increases substantially.

## Conclusion

The **t3.small** instance provides the most cost-effective balance between performance and expenditure for the CloudMart project. It delivers sufficient compute resources for hosting the five microservices while keeping infrastructure costs low, making it the preferred choice for this academic deployment.
