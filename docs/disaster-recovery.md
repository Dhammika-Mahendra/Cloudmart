# CloudMart Disaster Recovery Notes

## Targets

- RTO: 2 hours for the baseline EKS application.
- RPO: 24 hours for user data and Kubernetes resource state.

## Database Backups

RDS automated backups are configured with 7-day retention in the Terraform environment stacks. Restore testing should create a separate test instance from a point in time, verify login/profile data, and then destroy the test instance.

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
