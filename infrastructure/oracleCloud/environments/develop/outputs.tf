output "cluster_id" {
  value = module.oke.cluster_id
}

output "kubeconfig" {
  value     = module.oke.kubeconfig
  sensitive = true
}

output "vcn_id" {
  value = module.networking.vcn_id
}

output "cluster_private_ip" {
  value       = split(":", module.oke.cluster_endpoint["private-endpoint"])[0]
  description = "The raw private IP of the Kubernetes API master endpoint."
}

output "bastion_id" {
  value       = module.networking.bastion_id
  description = "The OCID of the newly created OCI Bastion."
}