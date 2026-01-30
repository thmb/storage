variable "kubernetes_namespace" {
  description = "Kubernetes namespace for SeaweedFS operator."
  default     = "seaweedfs-operator"
  type        = string
}

variable "chart_version" {
  description = "SeaweedFS operator Helm chart version."
  default     = "0.1.12"
  type        = string
}

variable "webhook_enabled" {
  description = "Enable SeaweedFS operator webhooks. Note: Should be false initially due to cert issues."
  default     = false
  type        = bool
}
