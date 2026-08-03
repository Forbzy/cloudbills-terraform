provider "kubernetes" {

  host = module.oke.cluster_endpoint

  cluster_ca_certificate = base64decode(
    module.oke.cluster_ca
  )

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