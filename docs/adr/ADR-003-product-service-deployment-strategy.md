# ADR-003: Product Service Deployment Strategy

## Status

Accepted

## Context

The product-service is user-facing and likely to receive frequent updates. The deployment method must reduce downtime while remaining simple enough for the team to operate during the live demo.

## Decision

Use Kubernetes rolling updates for the baseline deployment with `maxSurge: 1` and `maxUnavailable: 0`. Add canary deployment with Argo Rollouts later if time allows.

## Consequences

Rolling updates are easy to understand, work with native Kubernetes, and preserve availability when readiness probes are correct. They provide less risk control than canary releases because all traffic gradually moves to the new version without metric-based gating.

## Alternatives Considered

- Blue/green deployment: fast rollback and clean separation, but requires duplicate capacity and extra routing logic.
- Canary deployment: best progressive delivery option, but needs Argo Rollouts or Flagger plus reliable metrics before it is safe to depend on.
- Recreate deployment: simplest technically, but causes downtime and fails the production-readiness goal.
