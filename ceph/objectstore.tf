# ==============================================================================
# OBJECT STORAGE (RGW / S3)   —   var.install_object_store
#
# Creates a CephObjectStore CR and a kubernetes StorageClass for
# ObjectBucketClaims (OBC). Exposes an S3-compatible endpoint via the
#
# OBC provisioner: rook-ceph.ceph.rook.io/bucket
# S3 endpoint:     http://rook-ceph-rgw-ceph-objectstore.<namespace>.svc:<port>
# ==============================================================================

resource "kubernetes_manifest" "ceph_object_store" {
  count = var.install_object_store ? 1 : 0

  manifest = {
    apiVersion = "ceph.rook.io/v1"
    kind       = "CephObjectStore"

    metadata = {
      name      = "ceph-objectstore"
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

      dataPool = {
        failureDomain = "host"
        replicated = {
          size                   = 1
          requireSafeReplicaSize = false
        }
      }

      preservePoolsOnDelete = false

      gateway = {
        port      = var.rgw_port
        instances = 1
        resources = local.res_medium
      }
    }
  }
}


# ObjectBucketClaim StorageClass — used by applications to request S3 buckets.
# The OBC provisioner name is always <cluster-namespace>.ceph.rook.io/bucket.
resource "kubernetes_storage_class_v1" "ceph_bucket" {
  count = var.install_object_store ? 1 : 0

  metadata {
    name = "ceph-bucket"
  }

  storage_provisioner = "${var.kubernetes_namespace}.ceph.rook.io/bucket"
  reclaim_policy      = "Delete"

  parameters = {
    objectStoreName      = kubernetes_manifest.ceph_object_store[0].manifest.metadata.name
    objectStoreNamespace = var.kubernetes_namespace
    region               = "us-east-1"
  }
}
