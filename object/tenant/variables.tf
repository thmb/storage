variable "cluster_name" {
  description = "Name of the SeaweedFS cluster."
  type        = string
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for SeaweedFS cluster."
  default     = "default"
  type        = string
}

variable "seaweedfs_image" {
  description = "SeaweedFS container image."
  default     = "chrislusf/seaweedfs:latest"
  type        = string
}

variable "master_replicas" {
  description = "Number of master server replicas."
  default     = 1
  type        = number
}

variable "volume_replicas" {
  description = "Number of volume server replicas."
  default     = 1
  type        = number
}

variable "volume_storage_size" {
  description = "Storage size for each volume server."
  default     = "10Gi"
  type        = string
}

variable "filer_replicas" {
  description = "Number of filer replicas."
  default     = 1
  type        = number
}

