locals {
  release_name = "seaweedfs-operator"
}


# ==============================================================================
# NAMESPACE
# ==============================================================================

resource "kubernetes_namespace_v1" "seaweedfs_operator" {
  metadata {
    name = var.kubernetes_namespace
    labels = {
      name = var.kubernetes_namespace
    }
  }
}

# ==============================================================================
# HELM RELEASE
# ==============================================================================

resource "helm_release" "seaweedfs_operator" {
  name       = local.release_name
  namespace  = kubernetes_namespace_v1.seaweedfs_operator.metadata[0].name
  repository = "https://seaweedfs.github.io/seaweedfs-operator/"
  chart      = "seaweedfs-operator"
  version    = var.chart_version

  create_namespace = false

  values = [
    yamlencode({
      webhook = {
        enabled = var.webhook_enabled
      }
    })
  ]

  depends_on = [kubernetes_namespace_v1.seaweedfs_operator]
}
