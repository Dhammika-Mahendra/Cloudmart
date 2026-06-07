# CloudMart Disaster Recovery Notes

## Targets

- RTO: 2 hours for the baseline EKS application.
- RPO: 24 hours for user data and Kubernetes resource state.

## Database Backups

RDS automated backups should be configured with 7-day retention for final evidence. The staging stack defaults to `0` only because some AWS Free Tier restricted accounts reject automated backups with `FreeTierRestrictionError`. When the account allows it, set `rds_backup_retention_days = 7`, apply Terraform, and restore-test into a separate test instance.

## Kubernetes Resource Backup

Run this after a successful deployment:

```bash
scripts/backup-k8s-resources.sh cloudmart-prod backups/k8s
```

Restore baseline Kubernetes resources from Git and the backup artifact:

```bash
kubectl apply -k k8s/base
kubectl apply -f backups/k8s/cloudmart-prod-resources.yaml
```

For a stronger production setup, install Velero with an S3 backup location and schedule daily namespace backups.
