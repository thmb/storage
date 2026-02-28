# ==============================================================================
# SECRET (App User Credentials)
# ==============================================================================

resource "kubernetes_secret_v1" "credential" {
  metadata {
    name      = "${var.cluster_name}-credential"
    namespace = var.kubernetes_namespace
  }

  data = {
    username = var.database_owner
    password = var.database_password
  }

  type = "kubernetes.io/basic-auth"
}


# ==============================================================================
# POSTGRESQL CLUSTER
# ==============================================================================

resource "kubernetes_manifest" "postgres_cluster" {
  manifest = {
    apiVersion = "postgresql.cnpg.io/v1"
    kind       = "Cluster"

    metadata = {
      name      = var.cluster_name
      namespace = var.kubernetes_namespace
    }

    spec = {
      instances = 1

      imageName = "ghcr.io/cloudnative-pg/postgresql:${var.postgres_version}"

      postgresql = {
        parameters = {
          max_connections = "100"
          shared_buffers  = "256MB"
        }
      }

      bootstrap = {
        initdb = {
          database = var.database_name
          owner    = var.database_owner
          secret = {
            name = kubernetes_secret_v1.credential.metadata[0].name
          }
        }
      }

      storage = {
        size         = var.storage_size
        storageClass = var.storage_class
      }

      resources = {
        requests = {
          memory = "256Mi"
          cpu    = "100m"
        }
        limits = {
          memory = "1Gi"
          cpu    = "500m"
        }
      }
    }
  }
}
