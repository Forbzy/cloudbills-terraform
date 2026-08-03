variable "compartment_ocid" {
  description = "OCI compartment OCID"
  type        = string
}

variable "cluster_name" {
  default = "cloudbills"
}

variable "kubernetes_version" {
  default = "v1.33.1"
}

variable "node_shape" {
  description = "OCI compute shape for worker nodes"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 1
}

variable "region" {
  type = string
}