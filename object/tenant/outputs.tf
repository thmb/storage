output "cluster_name" {
  description = "SeaweedFS cluster name."
  value       = var.cluster_name
}

output "namespace" {
  description = "Kubernetes namespace."
  value       = var.kubernetes_namespace
}

output "master_replicas" {
  description = "Number of master server replicas."
  value       = var.master_replicas
}

output "volume_replicas" {
  description = "Number of volume server replicas."
  value       = var.volume_replicas
}

output "filer_replicas" {
  description = "Number of filer replicas."
  value       = var.filer_replicas
}

output "s3_endpoint" {
  description = "S3 API endpoint."
  value       = "http://${var.cluster_name}-filer.${var.kubernetes_namespace}.svc:8333"
}
