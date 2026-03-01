locals {
  app_name = "admin"

  labels = {
    app       = local.app_name
    component = "database-admin"
    managedBy = "terraform"
  }
}


# ==============================================================================
# NAMESPACE
# ==============================================================================

resource "kubernetes_namespace_v1" "admin" {
  metadata {
    name = var.kubernetes_namespace
    labels = {
      name = var.kubernetes_namespace
    }
  }
}


# ==============================================================================
# SECRET
# ==============================================================================

resource "kubernetes_secret_v1" "admin" {
  metadata {
    name      = "${local.app_name}-secret"
    namespace = kubernetes_namespace_v1.admin.metadata[0].name
    labels    = local.labels
  }

  data = {
    PGADMIN_DEFAULT_EMAIL    = var.admin_email
    PGADMIN_DEFAULT_PASSWORD = var.admin_password
  }

  type = "Opaque"
}


# ==============================================================================
# CONFIGMAP
# ==============================================================================

resource "kubernetes_config_map_v1" "admin" {
  metadata {
    name      = "${local.app_name}-config"
    namespace = kubernetes_namespace_v1.admin.metadata[0].name
    labels    = local.labels
  }

  data = {
    PGADMIN_CONFIG_SERVER_MODE              = "True"
    PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED = "False"
    PGADMIN_LISTEN_PORT                     = "80"
  }
}


# ==============================================================================
# DEPLOYMENT
# ==============================================================================

resource "kubernetes_deployment_v1" "admin" {
  metadata {
    name      = local.app_name
    namespace = kubernetes_namespace_v1.admin.metadata[0].name
    labels    = local.labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.app_name
      }
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        container {
          name  = "pgadmin"
          image = "dpage/pgadmin4:${var.image_tag}"

          port {
            name           = "http"
            container_port = 80
            protocol       = "TCP"
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.admin.metadata[0].name
            }
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.admin.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/misc/ping"
              port = 80
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/misc/ping"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }

        security_context {
          fs_group = 5050
        }
      }
    }
  }
}


# ==============================================================================
# SERVICE
# ==============================================================================

resource "kubernetes_service_v1" "admin" {
  metadata {
    name      = local.app_name
    namespace = kubernetes_namespace_v1.admin.metadata[0].name
    labels    = local.labels
  }

  spec {
    selector = {
      app = local.app_name
    }

    port {
      name        = "http"
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "ClusterIP"
  }
}


# ==============================================================================
# INGRESS
# ==============================================================================

resource "kubernetes_ingress_v1" "admin" {
  metadata {
    name      = local.app_name
    namespace = kubernetes_namespace_v1.admin.metadata[0].name
    labels    = local.labels

    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
  }

  spec {
    ingress_class_name = "traefik"

    rule {
      host = var.ingress_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service_v1.admin.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
