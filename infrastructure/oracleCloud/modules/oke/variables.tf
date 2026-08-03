variable "compartment_ocid" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "vcn_id" {
  type = string
}

variable "node_shape" {
  type = string
}

variable "node_count" {
  type = number
}

variable "tags" {
  type    = map(string)
  default = {}
}