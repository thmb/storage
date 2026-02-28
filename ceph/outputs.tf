output "cluster_name" {
  description = "CephCluster resource name."
  value       = var.cluster_name
}

output "namespace" {
  description = "Kubernetes namespace of the Ceph cluster."
  value       = var.kubernetes_namespace
}

output "object_store_endpoint" {
  description = "Internal S3/RGW endpoint (only meaningful when install_object_store = true)."
  value       = var.install_object_store ? "http://rook-ceph-rgw-ceph-objectstore.${var.kubernetes_namespace}.svc:${var.rgw_port}" : null
}

output "block_storage_class" {
  description = "StorageClass name for RBD block volumes."
  value       = var.install_block_storage ? "ceph-block" : null
}

output "filesystem_storage_class" {
  description = "StorageClass name for CephFS shared volumes."
  value       = var.install_filesystem ? "ceph-filesystem" : null
}

output "object_storage_class" {
  description = "StorageClass name for object bucket claims."
  value       = var.install_object_store ? "ceph-bucket" : null
}

