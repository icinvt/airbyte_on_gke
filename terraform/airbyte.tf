resource "kubernetes_namespace" "airbyte" {
  metadata {
    name = "airbyte"
  }
}

resource "helm_release" "airbyte" {
  name       = "airbyte"
  namespace  = kubernetes_namespace.airbyte.metadata[0].name
  chart      = "airbyte"
  repository = "https://airbytehq.github.io/helm-charts"

  values = [
    <<EOF
webapp:
  service:
    type: LoadBalancer
server:
  replicas: 1
EOF
  ]

  timeout = 1200 # タイムアウトを延長
}