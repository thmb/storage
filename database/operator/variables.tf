variable "kubernetes_namespace" {
  description = "Kubernetes namespace for CNPG operator."
  default     = "cnpg-system"
  type        = string
}

variable "image_repository" {
  description = "CNPG operator image repository."
  default     = "ghcr.io/cloudnative-pg/cloudnative-pg"
  type        = string
}

variable "image_tag" {
  description = "CNPG operator image tag."
  default     = "1.28.0"
  type        = string
}

variable "chart_version" {
  description = "CloudNativePG Helm chart version."
  default     = "0.27.0"
  type        = string
}
