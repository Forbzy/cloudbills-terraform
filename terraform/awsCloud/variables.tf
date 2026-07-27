variable "region" {
  default = "eu-west-2"
}


variable "cluster_name" {
  default = "demo-eks"
}


variable "kubernetes_version" {
  default = "1.31"
}


variable "node_instance_type" {
  default = "t3.micro"
}


variable "node_count" {
  default = 3
}