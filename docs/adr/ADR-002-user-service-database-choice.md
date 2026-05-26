# ADR-002: User Service Database Choice

## Status

Accepted

## Context

The user-service stores accounts, password hashes, login data, and profile records. This data requires relational consistency, predictable queries by email/user ID, encryption, backups, and point-in-time recovery.

## Decision

Use Amazon RDS for PostgreSQL as the managed relational database for user-service.

## Consequences

PostgreSQL gives strong consistency, mature SQL querying, SSL support, automated backups, and clear recovery procedures. It costs more than fully serverless storage when idle and requires subnet/security group design.

## Alternatives Considered

- DynamoDB: excellent for scale and low operations overhead, but less natural for relational user/account queries and transactional constraints.
- Aurora Serverless v2 PostgreSQL: operationally attractive and scalable, but can be more expensive and complex for the assignment's minimal baseline.
- In-memory storage: useful for local development only; it loses data and does not meet production requirements.
