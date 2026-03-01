output "database_url" {
  description = "PostgreSQL connection string."
  value       = "postgresql://${var.database_owner}@${var.cluster_name}-rw.${var.kubernetes_namespace}.svc:5432/${var.database_name}"
}

output "admin_url" {
  description = "URL to access PgAdmin web interface."
  value       = "http://${var.ingress_host}"
}
