output "ingress_url" {
  description = "URL to access PgAdmin web interface."
  value       = "http://${var.ingress_host}"
}

output "admin_email" {
  description = "PgAdmin admin email (for reference)."
  value       = var.admin_email
  sensitive   = true
}

