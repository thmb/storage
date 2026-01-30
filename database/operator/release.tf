locals {
  release_name = "cnpg"
}


# ==============================================================================
# NAMESPACE
# ==============================================================================

resource "kubernetes_namespace_v1" "cnpg" {
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

resource "helm_release" "cnpg" {
  name       = local.release_name
  namespace  = kubernetes_namespace_v1.cnpg.metadata[0].name
  repository = "https://cloudnative-pg.github.io/charts"
  chart      = "cloudnative-pg"
  version    = var.chart_version

  create_namespace = false

  values = [
    yamlencode({
      image = {
        repository = var.image_repository
        tag        = var.image_tag
      }
      crds = {
        create = true
      }
    })
  ]

  depends_on = [kubernetes_namespace_v1.cnpg]
}
