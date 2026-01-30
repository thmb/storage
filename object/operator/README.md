# SeaweedFS Operator Terraform Module

This Terraform module deploys the SeaweedFS operator into a Kubernetes cluster using the Helm provider. The SeaweedFS operator manages distributed object storage infrastructure.

## Features

- Deploys SeaweedFS operator via official Helm chart
- Creates dedicated namespace
- Configurable webhook settings (disabled by default)
- Minimal configuration with sensible defaults

## Requirements

- Terraform >= 1.14.0
- Kubernetes cluster (K3S recommended)
- Helm >= 3.0.0
- kubectl configured

## Usage

### Basic Deployment

```hcl
module "seaweedfs_operator" {
  source = "./operator"
}
```

### Custom Configuration

```hcl
module "seaweedfs_operator" {
  source = "./operator"

  kubernetes_namespace = "seaweedfs-system"
  chart_version        = "0.1.12"
  webhook_enabled      = false
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| kubernetes_namespace | Kubernetes namespace for SeaweedFS operator | string | `"seaweedfs-operator"` | no |
| chart_version | SeaweedFS operator Helm chart version | string | `"0.1.12"` | no |
| webhook_enabled | Enable SeaweedFS operator webhooks | bool | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| namespace | Kubernetes namespace where operator is deployed |
| release_name | Helm release name |
| chart_version | Deployed Helm chart version |
| webhook_enabled | Whether webhooks are enabled |

## Webhook Note

The SeaweedFS operator has a known issue with webhook certificates. It's recommended to keep `webhook_enabled = false` initially. After successful deployment, you can update to `webhook_enabled = true` if needed (requires cert-manager).

## Validation

```bash
# Initialize and apply
terraform init
terraform plan
terraform apply

# Verify deployment
kubectl get pods -n seaweedfs-operator
kubectl get crd | grep seaweedfs
```

## Next Steps

After deploying the operator, you can create SeaweedFS clusters using the `Seaweed` custom resource. See the tenant module for automated cluster provisioning.

## References

- [SeaweedFS Operator GitHub](https://github.com/seaweedfs/seaweedfs-operator)
- [SeaweedFS Operator Helm Chart](https://seaweedfs.github.io/seaweedfs-operator/)
- [SeaweedFS Documentation](https://github.com/seaweedfs/seaweedfs/wiki)
