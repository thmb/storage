# CloudNativePG Operator Terraform Module

Simplified Terraform module for deploying the CloudNativePG (CNPG) operator on Kubernetes using Helm.

## Features

- ✅ **Official Helm Chart**: Uses CloudNativePG official Helm repository
- ✅ **Pinned Version**: Chart version locked for reproducibility
- ✅ **CRDs Managed**: Automatically installs Custom Resource Definitions
- ✅ **Simple Configuration**: Minimal variables with sensible defaults
- ✅ **Production-Ready**: Battle-tested PostgreSQL operator

## What is CloudNativePG?

CloudNativePG is a Kubernetes operator that covers the full lifecycle of a highly available PostgreSQL database cluster with a primary/standby architecture using native streaming replication.

## Resources Created

| Resource | Description |
|----------|-------------|
| `kubernetes_namespace_v1` | Dedicated namespace (cnpg-system) |
| `helm_release` | CNPG operator Helm chart deployment |
| CRDs | PostgreSQL cluster definitions (Cluster, Backup, etc.) |

## Prerequisites

- Kubernetes cluster (any distribution)
- Terraform >= 1.14.0
- Helm provider >= 3.0.0
- Kubernetes provider >= 3.0.0

## Quick Start

### 1. Configure Variables (Optional)

```bash
cd /opt/github/thmb/storage/database/operator
cp terraform.tfvars.example terraform.tfvars
```

The defaults should work for most cases. Edit only if you need custom values:

```hcl
kubernetes_namespace = "cnpg-system"
image_repository     = "ghcr.io/cloudnative-pg/cloudnative-pg"
image_tag            = "1.28.0"
chart_version        = "0.27.0"
```

### 2. Configure Providers

The module requires configured Helm and Kubernetes providers. Add to your root module:

```hcl
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Verify Installation

```bash
# Check operator pod is running
kubectl get pods -n cnpg-system

# Verify CRDs are installed
kubectl get crds | grep cnpg

# Check operator logs
kubectl logs -n cnpg-system -l app.kubernetes.io/name=cloudnative-pg -f
```

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `kubernetes_namespace` | Namespace for operator | `cnpg-system` | No |
| `image_repository` | Operator container image | `ghcr.io/cloudnative-pg/cloudnative-pg` | No |
| `image_tag` | Operator image version | `1.28.0` | No |
| `chart_version` | Helm chart version | `0.27.0` | No |

### Versions

- **Chart Version**: `0.27.0` (configurable via `chart_version`)
- **Operator Version**: `1.28.0` (configurable via `image_tag`)

## Outputs

```bash
# Get namespace
terraform output namespace

# Get Helm release name
terraform output release_name

# Get deployed versions
terraform output chart_version
terraform output operator_version
```

## Usage Example

### Standalone Module

```hcl
module "cnpg_operator" {
  source = "./storage/database/operator"

  kubernetes_namespace = "cnpg-system"
  image_tag            = "1.28.0"
  chart_version        = "0.27.0"
}

output "cnpg_namespace" {
  value = module.cnpg_operator.namespace
}
```

### Create a PostgreSQL Cluster

After deploying the operator, create a PostgreSQL cluster:

```yaml
# postgres-cluster.yaml
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: postgres-cluster
  namespace: default
spec:
  instances: 3
  primaryUpdateStrategy: unsupervised
  
  postgresql:
    parameters:
      max_connections: "100"
      shared_buffers: "256MB"
  
  bootstrap:
    initdb:
      database: app
      owner: app
      secret:
        name: app-user-credentials
  
  storage:
    size: 10Gi
    storageClass: local-path
```

Apply it:

```bash
kubectl apply -f postgres-cluster.yaml
```

## Useful Commands

```bash
# Check operator status
kubectl get deployment -n cnpg-system
kubectl get pods -n cnpg-system

# List installed CRDs
kubectl get crds | grep postgresql.cnpg.io

# View operator logs
kubectl logs -n cnpg-system -l app.kubernetes.io/name=cloudnative-pg -f

# List PostgreSQL clusters (after creating some)
kubectl get clusters.postgresql.cnpg.io -A

# Describe a cluster
kubectl describe cluster postgres-cluster

# Delete operator (be careful!)
terraform destroy
```

## Upgrading the Operator

To upgrade to a newer version:

1. **Update chart version** in `terraform.tfvars`:
   ```hcl
   chart_version = "0.28.0"  # New chart version
   ```

2. **Update operator image** in `terraform.tfvars`:
   ```hcl
   image_tag = "1.29.0"  # New operator version
   ```

3. **Apply changes**:
   ```bash
   terraform plan
   terraform apply
   ```

The Helm chart will perform a rolling upgrade of the operator.

## Troubleshooting

### Operator Not Starting

```bash
# Check pod status
kubectl get pods -n cnpg-system

# Check pod events
kubectl describe pod -n cnpg-system -l app.kubernetes.io/name=cloudnative-pg

# View logs
kubectl logs -n cnpg-system -l app.kubernetes.io/name=cloudnative-pg
```

### CRDs Not Created

```bash
# Verify CRDs are installed
kubectl get crds | grep postgresql.cnpg.io

# Should see:
# - clusters.postgresql.cnpg.io
# - backups.postgresql.cnpg.io
# - scheduledbackups.postgresql.cnpg.io
# - poolers.postgresql.cnpg.io
```

If CRDs are missing, check Helm release:

```bash
helm list -n cnpg-system
helm get values cnpg -n cnpg-system
```

### Check Operator Version

```bash
kubectl get deployment -n cnpg-system cnpg-cloudnative-pg -o jsonpath='{.spec.template.spec.containers[0].image}'
```

## Next Steps

After deploying the operator:

1. **Create a PostgreSQL cluster** using the Cluster CRD
2. **Configure backups** using the Backup and ScheduledBackup CRDs
3. **Set up connection pooling** using the Pooler CRD
4. **Monitor with Prometheus** (operator exposes metrics)

See the [CloudNativePG documentation](https://cloudnative-pg.io/documentation/) for complete guides.

## Cleanup

To remove the operator and all CRDs:

```bash
terraform destroy
```

**Warning**: This will delete all PostgreSQL clusters managed by the operator if CRDs are removed.

## Links

- [CloudNativePG Documentation](https://cloudnative-pg.io/documentation/)
- [CloudNativePG GitHub](https://github.com/cloudnative-pg/cloudnative-pg)
- [Helm Chart Repository](https://github.com/cloudnative-pg/charts)
- [Operator Hub](https://operatorhub.io/operator/cloudnative-pg)
