# ADR-002: Selection of Amazon RDS PostgreSQL for User-Service Database

## Status

Accepted

## Context

The CloudMart **user-service** stores and manages:

* User accounts
* Login credentials
* User profiles
* User-related transactional data

The database solution must provide:

* Relational data modelling
* ACID transactions
* SQL querying capabilities
* Automated backups
* Encryption at rest and in transit
* Low operational overhead
* Cost-effective deployment suitable for an academic project

---

## Decision

Use **Amazon RDS PostgreSQL (db.t3.micro)** as the database for the user-service.

---

## Option Comparison

| Option                       | Type                             | Advantages                                                                                 | Disadvantages                                          | Decision |
| ---------------------------- | -------------------------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------ | -------- |
| **Amazon RDS PostgreSQL**    | Managed Relational Database      | ACID compliance, SQL support, automated backups, easy management, PostgreSQL compatibility | Limited horizontal scaling compared to NoSQL           | Selected |
| **Amazon Aurora PostgreSQL** | Managed Relational Database      | High performance, automatic scaling, high availability                                     | Higher cost than standard RDS                          | Rejected |
| **Amazon DynamoDB**          | NoSQL Key-Value Database         | Serverless, highly scalable, low latency                                                   | Poor fit for relational user data and joins            | Rejected |
| **Amazon DocumentDB**        | NoSQL Document Database          | Flexible schema, managed service                                                           | Not suitable for relational user-account relationships | Rejected |
| **PostgreSQL on EC2**        | Self-Managed Relational Database | Full administrative control                                                                | Manual maintenance, backups, patching, monitoring      | Rejected |

---

## Cost Comparison (Mumbai Region - ap-south-1)

| Service                          | Estimated Monthly Cost | Free Tier Eligibility                         | Notes                                   |
| -------------------------------- | ---------------------- | --------------------------------------------- | --------------------------------------- |
| **RDS PostgreSQL (db.t3.micro)** | ~$13–15/month          | Eligible (750 hrs/month for new AWS accounts) | Lowest-cost managed relational database |
| Aurora PostgreSQL                | ~$40–60+/month         | No                                            | Overkill for assignment workload        |
| DynamoDB                         | Pay-per-request        | Free tier available                           | Better suited for product catalog data  |
| DocumentDB                       | ~$35+/month            | No                                            | Higher cost and unsuitable data model   |
| PostgreSQL on EC2 (t3.micro)     | ~$8–10/month           | Eligible                                      | Requires manual administration          |

*Costs are approximate and may vary based on storage and usage.*

---

## Rationale

### Functional Fit

| Requirement                  | RDS PostgreSQL |
| ---------------------------- | -------------- |
| Relational Schema            | Supported      |
| SQL Queries                  | Supported      |
| ACID Transactions            | Supported      |
| Foreign Keys & Relationships | Supported      |
| User Authentication Data     | Supported      |
| Backup & Recovery            | Automated      |
| Encryption                   | Supported      |
| AWS Integration              | Native         |

The user-service manages highly structured relational data. PostgreSQL supports relationships between users, profiles, and application records while maintaining transactional consistency.

### Operational Benefits

| Feature                         | Benefit                                 |
| ------------------------------- | --------------------------------------- |
| Automated Backups               | Supports disaster recovery requirements |
| Point-in-Time Recovery          | Enables data restoration                |
| AWS Secrets Manager Integration | Secure credential management            |
| KMS Encryption                  | Data protection at rest                 |
| SSL/TLS Support                 | Secure communication                    |
| Managed Patching                | Reduced administrative effort           |

### Cost Benefits

* Eligible for AWS Free Tier in many educational environments.
* Lower operational cost than self-managed databases when maintenance effort is considered.
* Significantly cheaper than Aurora while providing all required functionality.
* Storage requirements for user data are expected to remain small during the project lifecycle.

---

## Consequences

### Positive

* Meets all user-service functional requirements.
* Supports relational data modelling and transactions.
* Simplifies administration through managed services.
* Provides built-in backup and recovery capabilities.
* Cost-effective for an academic deployment.

### Negative

* Less scalable than DynamoDB for extremely large workloads.
* May require instance upgrades if user traffic increases significantly.

---

## Conclusion

Amazon RDS PostgreSQL is the most suitable database solution for the CloudMart user-service because it provides relational data management, transactional consistency, security, and automated operations at a low cost. Compared to Aurora, DynamoDB, DocumentDB, and self-managed PostgreSQL, it offers the best balance of functionality, operational simplicity, and affordability for the project's requirements.
