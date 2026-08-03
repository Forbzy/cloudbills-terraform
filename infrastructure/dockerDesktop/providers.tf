provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }

  git = {
    url = var.github_repo

    http = {
      username = var.github_username
      password = var.github_token
    }
  }
}

provider "github" {
  owner = var.github_owner
  token = var.github_token
}