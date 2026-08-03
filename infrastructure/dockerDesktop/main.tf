resource "flux_bootstrap_git" "cloudbills" {
  path = "clusters/local"
}

resource "kubernetes_namespace" "cloudbills" {
  metadata {
    name = "cloudbills"
  }
}