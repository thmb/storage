variable "kubernetes_namespace" {
  description = "Kubernetes namespace."
  default     = "database"
  type        = string
}

variable "image_tag" {
  description = "PgAdmin Docker image tag."
  default     = "latest"
  type        = string
}

variable "admin_email" {
  description = "PgAdmin login email address."
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "PgAdmin login password."
  type        = string
  sensitive   = true
}

variable "ingress_host" {
  description = "Ingress hostname for PgAdmin."
  default     = "admin.localhost"
  type        = string
}
