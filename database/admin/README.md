# PgAdmin Terraform Module

Simplified Terraform module for deploying PgAdmin 4 on Kubernetes with Traefik ingress.

## Features

- ✅ **Kubernetes-native**: Uses latest Kubernetes provider resources (v1)
- ✅ **Simple**: Minimal configuration with sensible defaults
- ✅ **Secure**: Credentials stored in Kubernetes secrets
- ✅ **Production-ready**: Includes health checks and resource limits
- ✅ **Traefik ingress**: Pre-configured for K3S default ingress controller

## Resources Created

| Resource | Description |
|----------|-------------|
| `kubernetes_namespace_v1` | Dedicated namespace (database-admin) |
| `kubernetes_secret_v1` | Admin credentials (email/password) |
| `kubernetes_config_map_v1` | PgAdmin server configuration |
| `kubernetes_deployment_v1` | PgAdmin application (1 replica) |
| `kubernetes_service_v1` | ClusterIP service on port 80 |
| `kubernetes_ingress_v1` | Traefik ingress for HTTP access |

## Prerequisites

- Kubernetes cluster (K3S recommended)
- Traefik ingress controller (default in K3S)
- Terraform >= 1.14.0
- Kubernetes provider >= 3.0.0

## Quick Start

### 1. Configure Variables

```bash
cd /opt/github/thmb/storage/database/admin
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
admin_email    = "admin@example.com"
admin_password = "YourSecurePassword123!"
ingress_host   = "admin.localhost"  # Optional: change domain
```

### 2. Configure Kubernetes Provider

The module requires a configured Kubernetes provider. Add to your root module or create a `provider.tf`:

```hcl
provider "kubernetes" {
  # Option 1: Use local kubeconfig
  config_path = "~/.kube/config"
  
  # Option 2: Remote cluster (from platform outputs)
  # host                   = var.kubernetes_host
  # token                  = var.kubernetes_token
  # cluster_ca_certificate = base64decode(var.kubernetes_certificate)
}
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Access PgAdmin

**Option 1: Local access (admin.localhost)**

Add to `/etc/hosts`:

```bash
echo "127.0.0.1 admin.localhost" | sudo tee -a /etc/hosts
```

Then open in browser: <http://admin.localhost>

**Option 2: Port forwarding**

```bash
kubectl port-forward -n database-admin svc/pgadmin 8080:80
```

Then open in browser: <http://localhost:8080>

### 5. Login

- **Email**: Your `admin_email` from terraform.tfvars
- **Password**: Your `admin_password` from terraform.tfvars

## Configuration

### Available Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `kubernetes_namespace` | Kubernetes namespace | `database` | No |
| `image_tag` | PgAdmin Docker image tag | `latest` | No |
| `admin_email` | PgAdmin login email | - | **Yes** |
| `admin_password` | PgAdmin login password | - | **Yes** |
| `ingress_host` | Ingress hostname | `admin.localhost` | No |

### Resource Limits (Fixed)

The module uses these resource limits:

- **Requests**: 100m CPU, 256Mi memory
- **Limits**: 500m CPU, 512Mi memory
- **Replicas**: 1 (single instance)
- **Persistence**: Disabled (data not persisted across restarts)

## Outputs

```bash
# Get namespace
terraform output namespace

# Get ingress URL
terraform output ingress_url

# Get service name
terraform output service_name
```

## Usage Example

### Standalone Module

```hcl
module "pgadmin" {
  source = "./storage/database/admin"

  admin_email    = "admin@example.com"
  admin_password = "super-secret-password"
  ingress_host   = "admin.localhost"
}

output "pgadmin_url" {
  value = module.pgadmin.ingress_url
}
```

### Connect to PostgreSQL Database

Once logged into PgAdmin:

1. Click **Add New Server**
2. **General** tab:
   - Name: `My Database`
3. **Connection** tab:
   - Host: `postgres-service.namespace.svc.cluster.local`
   - Port: `5432`
   - Username: `postgres`
   - Password: Your database password
   - Save password: ✓
4. Click **Save**

## Useful Commands

```bash
# Check deployment status
kubectl get all -n database-admin

# View logs
kubectl logs -n database-admin -l app=pgadmin -f

# Describe pod
kubectl describe pod -n database-admin -l app=pgadmin

# Restart deployment
kubectl rollout restart deployment/pgadmin -n database-admin

# Delete everything
terraform destroy
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n database-admin
kubectl describe pod <pod-name> -n database-admin
kubectl logs <pod-name> -n database-admin
```

### Access Issues

If you cannot access PgAdmin:

1. **Check pod is running**: `kubectl get pods -n database-admin`
2. **Verify service**: `kubectl get svc -n database-admin`
3. **Check ingress**: `kubectl get ingress -n database-admin`
4. **Test port-forward**: `kubectl port-forward -n database-admin svc/pgadmin 8080:80`
5. **Access via**: <http://localhost:8080>

### Hostname Resolution (localhost)

For `admin.localhost` to work on your local machine, add it to `/etc/hosts`:

```bash
echo "127.0.0.1 admin.localhost" | sudo tee -a /etc/hosts
```

Or access via port-forwarding (see above).

## Security Recommendations

1. **Change default credentials**: Never use example credentials
2. **Use strong passwords**: Generate secure passwords (`openssl rand -base64 32`)
3. **Regular updates**: Pin specific versions instead of `latest`
4. **Restrict ingress**: Use NetworkPolicies or Traefik middleware for IP restrictions

## Cleanup

To remove all resources:

```bash
terraform destroy
```

This will delete the namespace and all resources within it.
