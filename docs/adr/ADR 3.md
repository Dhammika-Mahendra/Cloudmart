# ADR-003: Deployment Strategy – Kubernetes Rolling Updates

## Status

Accepted

## Context

The CloudMart platform consists of five microservices deployed on a managed Kubernetes cluster. The team consists of beginner-level cloud and Kubernetes practitioners completing an academic assignment. A deployment strategy was required for application updates while maintaining service availability.

The following deployment strategies were evaluated:

| Strategy       | Advantages                                                                                          | Disadvantages                                                                          |
| -------------- | --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Rolling Update | Simple to configure, built into Kubernetes, no additional infrastructure required, minimal downtime | Rollback affects existing deployment                                                   |
| Blue/Green     | Near-zero downtime, easy rollback                                                                   | Requires duplicate environments, higher infrastructure cost and operational complexity |
| Canary         | Gradual risk reduction, production testing with small user groups                                   | Requires advanced traffic management, monitoring, and operational expertise            |

## Decision

The project will use the **Kubernetes Rolling Update** deployment strategy.

Kubernetes Deployments natively support rolling updates and the project configuration uses:

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 0
```

This ensures that new pods are created before old pods are terminated, maintaining service availability during deployments.

## Rationale

| Consideration           | Rolling Update Assessment                                            |
| ----------------------- | -------------------------------------------------------------------- |
| Team Experience         | Best suited for beginner-level Kubernetes users                      |
| Complexity              | Low; supported natively by Kubernetes                                |
| Infrastructure Cost     | No additional environments or resources required                     |
| Learning Objectives     | Aligns with core Kubernetes deployment concepts taught in the module |
| Operational Overhead    | Minimal monitoring and traffic-routing requirements                  |
| Assignment Requirements | Explicitly required in the project specification                     |

Blue/Green deployment would require maintaining two complete application environments, increasing both cost and configuration effort. Canary deployment would require advanced traffic splitting, observability, and release management techniques that are beyond the scope of this academic project.

## Consequences

### Positive

* Simple and easy to implement.
* Meets assignment requirements.
* No additional infrastructure costs.
* Supported directly by Kubernetes Deployments.
* Easier for all group members to understand, operate, and troubleshoot.

### Negative

* Rollbacks are slower than Blue/Green deployments.
* Defective versions may briefly affect some users before rollback.
* Does not provide gradual traffic testing like Canary deployments.

## Conclusion

Rolling Updates provide the best balance of simplicity, cost-efficiency, and operational manageability for the CloudMart project. Given the team's beginner skill level and the academic nature of the assignment, Rolling Updates are the most appropriate deployment strategy.
