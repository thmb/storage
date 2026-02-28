# ==============================================================================
# FILESYSTEM STORAGE (CephFS)   —   var.install_filesystem
#
# Creates a CephFilesystem CR and a kubernetes StorageClass backed by the
# Ceph CSI CephFS driver. Suitable for ReadWriteMany PersistentVolumes
# (shared mounts across multiple pods).
#
# Requires: csi.enableCephfsDriver = true in platform/addons/cephoperator.tf
#
# CSI provisioner: <namespace>.cephfs.csi.ceph.com
# Secrets:         rook-csi-cephfs-provisioner / rook-csi-cephfs-node
#                  (created automatically by the operator on cluster ready)
# ==============================================================================

resource "kubernetes_manifest" "ceph_filesystem" {
  count = var.install_filesystem ? 1 : 0

  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephFilesystem"

    metadata = {
      name      = "ceph-filesystem"
      namespace = var.kubernetes_namespace
    }

    spec = {
      metadataPool = {
        failureDomain = "host"
        replicated = {
          size                   = 1
          requireSafeReplicaSize = false
        }
      }

      dataPools = [{
        name          = "data0"
        failureDomain = "host"
        replicated = {
          size                   = 1
          requireSafeReplicaSize = false
        }
      }]

      preserveFilesystemOnDelete = false

      metadataServer = {
        activeCount   = 1
        activeStandby = false
        resources     = local.res_medium
      }
    }
  }
}


resource "kubernetes_storage_class_v1" "ceph_filesystem" {
  count = var.install_filesystem ? 1 : 0

  metadata {
    name = "ceph-filesystem"
  }

  storage_provisioner = "${var.kubernetes_namespace}.cephfs.csi.ceph.com"
  reclaim_policy      = "Delete"

  parameters = {
    clusterID = var.kubernetes_namespace
    fsName    = kubernetes_manifest.ceph_filesystem[0].manifest.metadata.name
    # Pool name follows Rook's convention: <fsName>-<dataPool.name>
    pool = "ceph-filesystem-data0"

    "csi.storage.k8s.io/provisioner-secret-name"            = "rook-csi-cephfs-provisioner"
    "csi.storage.k8s.io/provisioner-secret-namespace"       = var.kubernetes_namespace
    "csi.storage.k8s.io/controller-expand-secret-name"      = "rook-csi-cephfs-provisioner"
    "csi.storage.k8s.io/controller-expand-secret-namespace" = var.kubernetes_namespace
    "csi.storage.k8s.io/node-stage-secret-name"             = "rook-csi-cephfs-node"
    "csi.storage.k8s.io/node-stage-secret-namespace"        = var.kubernetes_namespace
  }
}
