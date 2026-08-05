output "vcn_id" {
  description = "VCN OCID"
  value       = oci_core_virtual_network.vcn.id
}

output "private_subnet_id" {
  description = "Private subnet OCID"
  value       = oci_core_subnet.private_subnet.id
}

output "public_subnet_id" {
  description = "Public subnet OCID"
  value       = oci_core_subnet.public_subnet.id
}

output "bastion_id" {
  value       = oci_bastion_bastion.flux_bastion.id
  description = "The OCID of the newly created OCI Bastion."
}