# ==============================================================================
# KUBERNETES CONNECTION
# ==============================================================================

variable "kubernetes_host" {
  description = "Kubernetes API server host."
  default     = "https://localhost:6443"
  type        = string
}

variable "kubernetes_token" {
  description = "Kubernetes API server token."
  nullable    = false
  sensitive   = true
  type        = string
}

variable "kubernetes_certificate" {
  description = "Kubernetes API server CA certificate (base64-encoded)."
  nullable    = false
  type        = string
}

# ==============================================================================
# CLUSTER
# ==============================================================================

variable "kubernetes_namespace" {
  description = "Namespace for the Ceph cluster."
  default     = "rook-ceph"
  type        = string
}

variable "cluster_name" {
  description = "Name of the CephCluster CR."
  default     = "rook-ceph"
  type        = string
}

variable "ceph_image_tag" {
  description = "Ceph container image tag."
  default     = "v19.2.3"
  type        = string
}

variable "data_host_path" {
  description = "Host path where Rook stores cluster metadata."
  default     = "/var/lib/rook"
  type        = string
}

variable "osd_data_path" {
  description = "Host directory path used for directory-based OSDs (dev/test only)."
  default     = "/var/lib/rook/osd-data"
  type        = string
}

variable "node_name" {
  description = "Kubernetes node name where the single-node cluster will run."
  type        = string
}

# ==============================================================================
# STORAGE TYPES (OPTIONAL)
# ==============================================================================

variable "install_object_store" {
  description = "Whether to deploy a CephObjectStore (S3-compatible RGW gateway)."
  default     = true
  type        = bool
}

variable "install_block_storage" {
  description = "Whether to deploy a CephBlockPool and its RBD StorageClass."
  default     = false
  type        = bool
}

variable "install_filesystem" {
  description = "Whether to deploy a CephFilesystem and its CephFS StorageClass."
  default     = false
  type        = bool
}

variable "rgw_port" {
  description = "HTTP port exposed by the RGW object-store gateway."
  default     = 80
  type        = number
}

