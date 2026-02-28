# ==============================================================================
# BLOCK STORAGE (RBD)   —   var.install_block_storage
#
# Creates a CephBlockPool CR and a kubernetes StorageClass backed by the
# Ceph CSI RBD driver. Suitable for ReadWriteOnce PersistentVolumes
# (databases, single-pod stateful workloads).
#
# CSI provisioner: <namespace>.rbd.csi.ceph.com
# Secrets:         rook-csi-rbd-provisioner / rook-csi-rbd-node
#                  (created automatically by the operator on cluster ready)
# ==============================================================================

resource "kubernetes_manifest" "ceph_block_pool" {
  count = var.install_block_storage ? 1 : 0

  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephBlockPool"

    metadata = {
      name      = "ceph-blockpool"
      namespace = var.kubernetes_namespace
    }

    spec = {
      failureDomain = "host"
      replicated = {
        size                   = 1
        requireSafeReplicaSize = false
      }
    }
  }
}


resource "kubernetes_storage_class_v1" "ceph_block" {
  count = var.install_block_storage ? 1 : 0

  metadata {
    name = "ceph-block"
    annotations = {
      # Make this the default StorageClass for the cluster
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "${var.kubernetes_namespace}.rbd.csi.ceph.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true

  parameters = {
    # The namespace of the CephCluster CR
    clusterID = var.kubernetes_namespace
    pool      = kubernetes_manifest.ceph_block_pool[0].manifest.metadata.name

    imageFormat   = "2"
    imageFeatures = "layering"

    "csi.storage.k8s.io/provisioner-secret-name"            = "rook-csi-rbd-provisioner"
    "csi.storage.k8s.io/provisioner-secret-namespace"       = var.kubernetes_namespace
    "csi.storage.k8s.io/controller-expand-secret-name"      = "rook-csi-rbd-provisioner"
    "csi.storage.k8s.io/controller-expand-secret-namespace" = var.kubernetes_namespace
    "csi.storage.k8s.io/node-stage-secret-name"             = "rook-csi-rbd-node"
    "csi.storage.k8s.io/node-stage-secret-namespace"        = var.kubernetes_namespace
  }
}
