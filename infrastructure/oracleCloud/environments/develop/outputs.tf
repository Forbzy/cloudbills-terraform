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