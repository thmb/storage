output "namespace" {
  description = "Kubernetes namespace where SeaweedFS operator is deployed."
  value       = kubernetes_namespace_v1.seaweedfs_operator.metadata[0].name
}

output "release_name" {
  description = "Helm release name for SeaweedFS operator."
  value       = helm_release.seaweedfs_operator.name
}

output "chart_version" {
  description = "SeaweedFS operator Helm chart version deployed."
  value       = var.chart_version
}

output "webhook_enabled" {
  description = "Whether webhooks are enabled for SeaweedFS operator."
  value       = var.webhook_enabled
}
