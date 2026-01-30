# PostgreSQL Cluster Terraform Module

Simplified Terraform module for deploying a PostgreSQL cluster using CloudNativePG.

## Features

- ✅ **Single Replica**: Simple, lean configuration
- ✅ **Secure Credentials**: Password managed via Terraform variables
- ✅ **kubernetes_manifest**: Direct CRD management
- ✅ **PostgreSQL 18**: Latest stable PostgreSQL version
- ✅ **Minimal Resources**: Optimized for development/small workloads

## Resources Created

| Resource | Description |
|----------|-------------|
| `kubernetes_secret_v1` | App user credentials |
| `kubernetes_manifest` | PostgreSQL Cluster CRD |

## Prerequisites

- Kubernetes cluster with CNPG operator installed
- Terraform >= 1.14.0
- Kubernetes provider >= 3.0.0

## Quick Start

### 1. Install CNPG Operator First

This module requires the CloudNativePG operator to be installed:

```bash
cd ../operator
terraform apply
```

### 2. Configure Variables

```bash
cd ../tenant
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
cluster_name         = "my-postgres"
kubernetes_namespace = "default"
database_name        = "myapp"
database_owner       = "myapp"
database_password    = "super-secret-password"
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Get Connection Details

```bash
# Get connection string
terraform output connection_string

# Get password (sensitive)
terraform output -raw app_password
```

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `cluster_name` | PostgreSQL cluster name | - | **Yes** |
| `kubernetes_namespace` | Kubernetes namespace | `default` | No |
| `database_name` | Initial database | `app` | No |
| `database_owner` | Database owner username | `app` | No |
| `database_password` | Database owner password | - | **Yes** |
| `storage_size` | Storage size | `10Gi` | No |
| `storage_class` | Storage class | `local-path` | No |
| `postgres_version` | PostgreSQL major version | `17` | No |

### Fixed Configuration

The module uses these fixed settings for simplicity:

- **Instances**: 1 (single replica, no HA)
- **Resources**: 
  - Requests: 100m CPU, 256Mi memory
  - Limits: 500m CPU, 1Gi memory
- **PostgreSQL Settings**:
  - max_connections: 100
  - shared_buffers: 256MB

## Outputs

```bash
# Cluster information
terraform output cluster_name
terraform output namespace
terraform output database_name

# Connection details
terraform output connection_string
terraform output app_password  # Sensitive
```

## Usage Example

### Standalone Module

```hcl
module "postgres" {
  source = "./storage/database/tenant"

  cluster_name         = "my-app-db"
  kubernetes_namespace = "production"
  database_name        = "myapp"
  database_owner       = "myapp"
  database_password    = var.postgres_password
  storage_size         = "50Gi"
}

output "db_connection" {
  value     = module.postgres.connection_string
  sensitive = true
}

output "db_password" {
  value     = module.postgres.app_password
  sensitive = true
}
```

### Connecting to PostgreSQL

**From within the cluster:**

```bash
# Connection details
HOST: <cluster_name>-rw.<namespace>.svc
PORT: 5432
DATABASE: <database_name>
USERNAME: <database_owner>
PASSWORD: <from terraform output app_password>

# Connection string
postgresql://<owner>:<password>@<cluster_name>-rw.<namespace>.svc:5432/<database_name>
```

**Using psql:**

```bash
# Port-forward to access locally
kubectl port-forward -n <namespace> svc/<cluster_name>-rw 5432:5432

# Connect
psql "postgresql://<owner>:<password>@localhost:5432/<database_name>"
```

## Useful Commands

### Check Cluster Status

```bash
# Get cluster status
kubectl get cluster -n <namespace>

# Describe cluster
kubectl describe cluster <cluster_name> -n <namespace>

# Check pods
kubectl get pods -n <namespace> -l cnpg.io/cluster=<cluster_name>
```

### Access Logs

```bash
# View PostgreSQL logs
kubectl logs -n <namespace> <cluster_name>-1

# Follow logs
kubectl logs -n <namespace> <cluster_name>-1 -f
```

### Connect via psql

```bash
# Port-forward
kubectl port-forward -n <namespace> svc/<cluster_name>-rw 5432:5432

# Connect
psql "postgresql://<owner>@localhost:5432/<database_name>"
# Password: <from terraform output>
```

### Get Password

```bash
# From Terraform output
terraform output -raw app_password

# From Kubernetes secret
kubectl get secret <cluster_name>-app-user -n <namespace> -o jsonpath='{.data.password}' | base64 -d
```

## Service Endpoints

CNPG creates multiple service endpoints:

| Service | Purpose | Endpoint |
|---------|---------|----------|
| `-rw` | Read-Write (Primary) | `<cluster_name>-rw.<namespace>.svc:5432` |
| `-ro` | Read-Only (Replicas) | `<cluster_name>-ro.<namespace>.svc:5432` |
| `-r` | Read (Any instance) | `<cluster_name>-r.<namespace>.svc:5432` |

For single replica deployments, all services point to the same pod.

## Scaling

To add replicas in the future, update the manifest:

```hcl
# In main.tf, change:
instances = 3  # Add replicas for high availability
```

Then apply:

```bash
terraform apply
```

CNPG will automatically provision and configure replicas with streaming replication.

## Upgrading PostgreSQL

To upgrade to a newer PostgreSQL version:

```hcl
# In terraform.tfvars
postgres_version = 18  # New major version
```

**Note**: CNPG handles in-place upgrades automatically for minor versions. Major version upgrades require additional steps.

## Troubleshooting

### Cluster Not Starting

```bash
# Check cluster status
kubectl get cluster <cluster_name> -n <namespace> -o yaml

# Check events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Check operator logs
kubectl logs -n cnpg-system -l app.kubernetes.io/name=cloudnative-pg -f
```

### Connection Issues

```bash
# Verify service exists
kubectl get svc -n <namespace> | grep <cluster_name>

# Test connectivity from another pod
kubectl run -it --rm debug --image=postgres:17 --restart=Never -- \
  psql "postgresql://<owner>@<cluster_name>-rw.<namespace>.svc:5432/<database_name>"
```

### Check Storage

```bash
# View PVCs
kubectl get pvc -n <namespace> | grep <cluster_name>

# Describe PVC
kubectl describe pvc <cluster_name>-1 -n <namespace>
```

## Cleanup

To remove the PostgreSQL cluster:

```bash
terraform destroy
```

**Warning**: This will delete the database and all data. Ensure you have backups if needed.

## Next Steps

For production deployments, consider:

1. **Add Replicas**: Set `instances = 3` for high availability
2. **Configure Backups**: Add backup configuration to the cluster spec
3. **Monitoring**: Enable Prometheus metrics
4. **Connection Pooling**: Deploy PgBouncer using CNPG Pooler CRD
5. **Custom Storage Class**: Use faster storage for production

## Links

- [CloudNativePG Documentation](https://cloudnative-pg.io/documentation/)
- [Cluster API Reference](https://cloudnative-pg.io/documentation/current/api_reference/)
- [PostgreSQL Configuration](https://www.postgresql.org/docs/current/runtime-config.html)
