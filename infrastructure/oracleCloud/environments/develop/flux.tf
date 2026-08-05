# 1. Generate a secure deploy keypair for Flux
resource "tls_private_key" "flux_deploy_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

# 2. Register the deploy key automatically to your SEPARATE Flux Git Repo
resource "github_repository_deploy_key" "flux" {
  provider   = github
  title      = "flux-oke-deploy-key"
  repository = "cloudbills-fluxcd"
  key        = tls_private_key.flux_deploy_key.public_key_openssh
  read_only  = "false"
}

# 3. Bootstrap FluxCD (Runs exactly once when the OKE cluster is ready)
resource "flux_bootstrap_git" "this" {
  depends_on = [
    github_repository_deploy_key.flux,
    module.oke # Ensures the cluster is fully ready first
  ]

  path = "gitops/clusters/develop"
}
