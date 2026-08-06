variable "use_tunnel" {
  type        = bool
  default     = true # Set to true when running locally or through a GitHub pipeline tunnel
  description = "Toggle this to switch between raw endpoint and local loopback tunnel paths."
}

provider "kubernetes" {
  # Dynamically routes to localhost if a tunnel is active, otherwise falls back to standard OKE outputs
  host = var.use_tunnel ? "https://127.0.0.1:6443" : module.oke.cluster_endpoint

  cluster_ca_certificate = base64decode(module.oke.cluster_ca)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "oci"
    args = [
      "ce",
      "cluster",
      "generate-token",
      "--cluster-id",
      module.oke.cluster_id
    ]
  }
}

provider "oci" {
  config_file_profile = "DEFAULT"
}

provider "github" {
  token = var.github_token # Needs write access to your cloudbills-fluxcd repo
  owner = "Forbzy"
}

provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
  git = {
    url = "https://github.com/Forbzy/cloudbills-fluxcd.git" # Targets your target separate repo
    http = {
      username = "Forbzy"
      password = var.github_token
    }
  }
}