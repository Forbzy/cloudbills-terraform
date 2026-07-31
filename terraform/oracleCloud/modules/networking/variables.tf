variable "compartment_ocid" {
  description = "OCI compartment OCID"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "control_plane_subnet_cidr" {
  type        = string
  default     = "10.0.0.0/28"
  description = "The CIDR block of the OKE control plane subnet"
}