output "cluster_id" {
  description = "OKE cluster OCID"
  value       = oci_containerengine_cluster.oke_cluster.id
}

output "kubeconfig" {
  description = "OKE kubeconfig"

  value = data.oci_containerengine_cluster_kube_config.oke.content
}

output "cluster_endpoint" {
  description = "OKE Kubernetes API endpoint"
  value       = data.oci_containerengine_cluster.oke.endpoints[0]
}