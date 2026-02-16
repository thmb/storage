# SeaweedFS Cluster Terraform Module

This Terraform module deploys a SeaweedFS cluster using the SeaweedFS operator with kubernetes_manifest. SeaweedFS provides distributed object storage with S3-compatible API.

## Features

- Deploys complete SeaweedFS cluster (Master, Volume, Filer)
- S3-compatible API (enabled by default)
- Embedded IAM for S3 authentication
- Configurable replicas for all components
- LevelDB2 backend for filer metadata
- Minimal configuration with sensible defaults

## Requirements

- Terraform >= 1.14.0
- Kubernetes cluster (K3S recommended)
- SeaweedFS operator installed (see operator module)
- kubectl configured

## Usage

### Basic Deployment

```hcl
module "seaweedfs_cluster" {
  source = "./tenant"

  cluster_name = "seaweedfs-prod"
}
```

### Custom Configuration

```hcl
module "seaweedfs_cluster" {
  source = "./tenant"

  cluster_name         = "seaweedfs-prod"
  kubernetes_namespace = "storage"
  
  master_replicas      = 3
  volume_replicas      = 3
  filer_replicas       = 2
  
  volume_storage_size  = "50Gi"
  
  seaweedfs_image      = "chrislusf/seaweedfs:3.70"
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| cluster_name | Name of the SeaweedFS cluster | string | - | yes |
| kubernetes_namespace | Kubernetes namespace | string | `"default"` | no |
| seaweedfs_image | SeaweedFS container image | string | `"chrislusf/seaweedfs:latest"` | no |
| master_replicas | Number of master server replicas | number | `1` | no |
| volume_replicas | Number of volume server replicas | number | `1` | no |
| volume_storage_size | Storage size per volume server | string | `"10Gi"` | no |
| filer_replicas | Number of filer replicas | number | `1` | no |


## Outputs

| Name | Description |
|------|-------------|
| cluster_name | SeaweedFS cluster name |
| namespace | Kubernetes namespace |
| master_replicas | Number of master replicas |
| volume_replicas | Number of volume replicas |
| filer_replicas | Number of filer replicas |
| s3_endpoint | S3 API endpoint URL |

## Architecture

SeaweedFS consists of three main components:

- **Master Servers**: Coordinate volume servers and manage file metadata
- **Volume Servers**: Store actual file data chunks
- **Filer**: Provides POSIX filesystem interface and S3 API

## S3 Access

S3 API is enabled by default and accessible at:

- Internal: `http://<cluster_name>-filer.<namespace>.svc:8333`
- IAM is embedded and runs on the same port (8333)

## Validation

```bash
# Initialize and apply
terraform init
terraform plan
terraform apply

# Verify deployment
kubectl get seaweed -n <namespace>
kubectl get pods -n <namespace>

# Test S3 endpoint
kubectl run -it --rm s3-test --image=amazon/aws-cli --restart=Never -- \
  s3 --endpoint-url=http://<cluster_name>-filer.<namespace>.svc:8333 ls
```

## Storage Backend

This module uses LevelDB2 for filer metadata storage. For production environments, consider configuring alternative backends like:
- PostgreSQL
- MySQL
- Redis
- Cassandra

Modify the `filer.config` in [main.tf](main.tf) to use a different backend.

## References

- [SeaweedFS Documentation](https://github.com/seaweedfs/seaweedfs/wiki)
- [SeaweedFS Operator](https://github.com/seaweedfs/seaweedfs-operator)
- [IAM Support](https://github.com/seaweedfs/seaweedfs-operator/blob/master/IAM_SUPPORT.md)
