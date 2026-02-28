terraform {
  required_version = ">= 1.14.0"

  backend "s3" {
    bucket                      = "thmb-state"
    key                         = "storage/ceph/terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints = {
      s3 = "https://99a835c188dc1c0a8dbf57494713c6ca.r2.cloudflarestorage.com"
    }
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }
  }
}


provider "kubernetes" {
  host                   = var.kubernetes_host
  token                  = var.kubernetes_token
  cluster_ca_certificate = var.kubernetes_certificate != "" ? base64decode(var.kubernetes_certificate) : null
}
