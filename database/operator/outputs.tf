output "namespace" {
  description = "Kubernetes namespace where CNPG operator is deployed."
  value       = kubernetes_namespace_v1.cnpg.metadata[0].name
}

output "release_name" {
  description = "Helm release name for CNPG operator."
  value       = helm_release.cnpg.name
}

output "chart_version" {
  description = "CNPG Helm chart version deployed."
  value       = var.chart_version
}

output "operator_version" {
  description = "CNPG operator image version deployed."
  value       = var.image_tag
}
