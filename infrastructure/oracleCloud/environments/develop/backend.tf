terraform {
  backend "oci" {
    bucket    = "terraform-state"
    namespace = "lrlzwqok77yg"
    region    = "uk-london-1"
    key       = "cloudbills/develop/terraform.tfstate"
  }
}