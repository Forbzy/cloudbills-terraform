terraform {
  required_version = ">= 1.8"

  required_providers {
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.5"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}