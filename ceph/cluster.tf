# ==============================================================================
# ROOK-CEPH CLUSTER
#
# Provisions the CephCluster CR directly via kubernetes_manifest.
# The Rook operator (platform/addons/cephoperator.tf) watches for this CR
# and reconciles all Ceph daemons automatically.
#
# Single-node K3S specifics:
#   - Directory-based OSDs  (no raw block devices required)
#   - Replication size 1    (requireSafeReplicaSize = false)
#   - mon.count = 1 + allowMultiplePerNode = true
#   - Crash / log collectors disabled to save resources
#
# Optional storage types live in their own files:
#   block.tf       — CephBlockPool  + StorageClass  (var.install_block_storage)
#   filesystem.tf  — CephFilesystem + StorageClass  (var.install_filesystem)
#   objectstore.tf — CephObjectStore + StorageClass (var.install_object_store)
# ==============================================================================

locals {
  # Shared resource profiles — referenced across all storage-type files.
  res_small = {
    requests = { cpu = "50m", memory = "128Mi" }
    limits   = { memory = "256Mi" }
  }

  res_medium = {
    requests = { cpu = "100m", memory = "256Mi" }
    limits   = { memory = "512Mi" }
  }

  res_large = {
    requests = { cpu = "100m", memory = "512Mi" }
    limits   = { memory = "2Gi" }
  }
}


resource "kubernetes_manifest" "ceph_cluster" {
  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephCluster"

    metadata = {
      name      = var.cluster_name
      namespace = var.kubernetes_namespace
    }

    spec = {
      cephVersion = {
        image            = "quay.io/ceph/ceph:${var.ceph_image_tag}"
        allowUnsupported = false
      }

      dataDirHostPath = var.data_host_path

      # Single-node: 1 monitor is sufficient
      mon = {
        count                = 1
        allowMultiplePerNode = true
      }

      mgr = {
        count                = 1
        allowMultiplePerNode = true
        modules              = [{ name = "rook", enabled = true }]
      }

      # Disable optional daemons to keep the footprint lean
      dashboard      = { enabled = false }
      crashCollector = { disable = true }
      logCollector   = { enabled = false }
      monitoring     = { enabled = false }

      # Directory-based OSDs — the path must exist on the node before
      # Rook provisions OSDs. Create it with:
      #   mkdir -p <osd_data_path> && chmod 700 <osd_data_path>
      storage = {
        useAllNodes   = false
        useAllDevices = false
        nodes = [{
          name        = var.node_name
          directories = [{ path = var.osd_data_path }]
        }]
      }

      resources = {
        mgr           = local.res_medium
        mon           = local.res_medium
        osd           = local.res_large
        prepareosd    = local.res_small
        "mgr-sidecar" = local.res_small
      }
    }
  }
}
