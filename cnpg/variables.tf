variable "cluster_name" {
  description = "Name of the PostgreSQL cluster."
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace."
  default     = "default"
  type        = string
}

variable "database_name" {
  description = "Initial database name to create."
  default     = "app"
  type        = string
}

variable "database_owner" {
  description = "Database owner username."
  default     = "app"
  type        = string
}

variable "database_password" {
  description = "Database owner password."
  type        = string
  sensitive   = true
}

variable "storage_size" {
  description = "Storage size for PostgreSQL data."
  default     = "10Gi"
  type        = string
}

variable "storage_class" {
  description = "Storage class for persistent volumes."
  default     = "local-path"
  type        = string
}

variable "postgres_version" {
  description = "PostgreSQL major version."
  default     = 18
  type        = number
}

# ADMIN

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
