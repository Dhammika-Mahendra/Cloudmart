# ADR-001: Kubernetes Node Instance Type

## Status

Accepted

## Context

CloudMart needs a low-cost EKS worker node type for the initial production-grade deployment. The cluster must run five microservices, support at least two worker nodes, and remain affordable for an academic project.

## Decision

Use `t3.medium` for the initial EKS managed node group, with desired capacity `2`, minimum `2`, and maximum `4`.

## Consequences

This keeps the first deployment simple because `t3.medium` supports standard x86 container images and has broad AWS availability. It is not the cheapest long-term option, and CPU credits may matter during sustained load testing.

## Alternatives Considered

- `t3.small`: cheaper, but the memory headroom is too tight for EKS system pods plus five services.
- `t4g.medium`: lower cost ARM option, but it requires confirming every container image and dependency supports ARM.
- `c6i.large`: stronger compute performance, but unnecessary for the initial low-traffic CloudMart workload.
