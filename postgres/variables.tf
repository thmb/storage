variable "cluster_name" {
  description = "Name of the PostgreSQL cluster."
  default     = "postgres-cluster"
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace."
  default     = "database"
  type        = string
}

variable "database_name" {
  description = "Initial database name to create."
  default     = "application"
  type        = string
}

variable "database_owner" {
  description = "Database owner username."
  sensitive   = true
  type        = string
}

variable "database_password" {
  description = "Database owner password."
  sensitive   = true
  type        = string
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
  sensitive   = true
  type        = string
}

variable "admin_password" {
  description = "PgAdmin login password."
  sensitive   = true
  type        = string
}

variable "ingress_host" {
  description = "Ingress hostname for PgAdmin."
  default     = "admin.localhost"
  type        = string
}
