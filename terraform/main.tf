terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8"
    }
  }
}

provider "google" {
  project = "orbital-alpha-316500" # GCPプロジェクトID
  region  = "asia-northeast1"
  zone    = "asia-northeast1-a"
}

provider "kubernetes" {
  host                   = google_container_cluster.airbyte-cluster.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.airbyte-cluster.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = google_container_cluster.airbyte-cluster.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.airbyte-cluster.master_auth[0].cluster_ca_certificate)
  }
}

resource "google_container_cluster" "airbyte-cluster" {
  name     = "airbyte-cluster"
  location = "asia-northeast1"

  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 50
  }

  network_policy {
    enabled = true
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
  }
}

resource "null_resource" "get_credentials" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials airbyte-cluster --zone=asia-northeast1"
  }

  depends_on = [google_container_cluster.airbyte-cluster]
}

data "google_client_config" "default" {}
