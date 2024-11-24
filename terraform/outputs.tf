output "gke_cluster_endpoint" {
  value = google_container_cluster.airbyte-cluster.endpoint
}

output "gke_cluster_name" {
  value = google_container_cluster.airbyte-cluster.name
}

# 必要に応じて、コメントアウトすること
#output "airbyte_webapp_external_ip" {
#  value = kubernetes_service.airbyte_webapp.status.load_balancer.ingress[0].ip
#}
