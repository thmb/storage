output "cluster_name" {
  description = "PostgreSQL cluster name."
  value       = var.cluster_name
}

output "namespace" {
  description = "Kubernetes namespace."
  value       = var.kubernetes_namespace
}

output "database_name" {
  description = "Initial database name."
  value       = var.database_name
}

output "database_owner" {
  description = "Database owner username."
  value       = var.database_owner
}

output "connection_string" {
  description = "PostgreSQL connection string."
  value       = "postgresql://${var.database_owner}@${var.cluster_name}-rw.${var.kubernetes_namespace}.svc:5432/${var.database_name}"
}

# ADMIN

output "ingress_url" {
  description = "URL to access PgAdmin web interface."
  value       = "http://${var.ingress_host}"
}

output "admin_email" {
  description = "PgAdmin admin email (for reference)."
  value       = var.admin_email
  sensitive   = true
}

