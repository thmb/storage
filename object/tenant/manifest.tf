# ==============================================================================
# SEAWEEDFS CLUSTER
# ==============================================================================

resource "kubernetes_manifest" "seaweedfs_cluster" {
  manifest = {
    apiVersion = "seaweed.seaweedfs.com/v1"
    kind       = "Seaweed"

    metadata = {
      name      = var.cluster_name
      namespace = var.kubernetes_namespace
    }

    spec = {
      image                 = var.seaweedfs_image
      volumeServerDiskCount = 1

      master = {
        replicas          = var.master_replicas
        volumeSizeLimitMB = 1024
      }

      volume = {
        replicas = var.volume_replicas
        requests = {
          storage = var.volume_storage_size
        }
      }

      filer = {
        replicas = var.filer_replicas
        s3 = {
          enabled = true
        }
        config = <<-EOT
          [leveldb2]
          enabled = true
          dir = "/data/filerldb2"
        EOT
      }
    }
  }
}
