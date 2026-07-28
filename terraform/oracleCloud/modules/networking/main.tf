#######################################
# Networking Module
#######################################

resource "oci_core_virtual_network" "vcn" {

  compartment_id = var.compartment_ocid

  display_name = "oke-vcn"

  cidr_block = "10.0.0.0/16"

  dns_label = "okevcn"
}

#######################################
# Internet Gateway
#######################################

resource "oci_core_internet_gateway" "igw" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_virtual_network.vcn.id

  display_name = "oke-igw"

  enabled = true
}

#######################################
# NAT Gateway
#######################################

resource "oci_core_nat_gateway" "nat" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_virtual_network.vcn.id

  display_name = "oke-nat"
}

#######################################
# OCI Services
#######################################

data "oci_core_services" "services" {}

#######################################
# Service Gateway
#######################################

resource "oci_core_service_gateway" "sgw" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_virtual_network.vcn.id

  display_name = "oke-service-gateway"

  services {
    service_id = data.oci_core_services.services.services[0].id
  }
}

#######################################
# Public Route Table
#######################################

resource "oci_core_route_table" "public" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_virtual_network.vcn.id

  display_name = "public-route-table"

  route_rules {

    destination = "0.0.0.0/0"

    destination_type = "CIDR_BLOCK"

    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

#######################################
# Private Route Table
#######################################

resource "oci_core_route_table" "private" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_virtual_network.vcn.id

  display_name = "private-route-table"

  route_rules {

    destination = "0.0.0.0/0"

    destination_type = "CIDR_BLOCK"

    network_entity_id = oci_core_nat_gateway.nat.id
  }

  route_rules {

    destination = data.oci_core_services.services.services[0].cidr_block

    destination_type = "SERVICE_CIDR_BLOCK"

    network_entity_id = oci_core_service_gateway.sgw.id
  }
}

#######################################
# Public Subnet
#######################################

resource "oci_core_subnet" "public_subnet" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_virtual_network.vcn.id

  cidr_block = "10.0.1.0/24"

  display_name = "public-subnet"

  route_table_id = oci_core_route_table.public.id

  prohibit_public_ip_on_vnic = false
}

#######################################
# Private Subnet
#######################################

resource "oci_core_subnet" "private_subnet" {

  compartment_id = var.compartment_ocid

  vcn_id = oci_core_virtual_network.vcn.id

  cidr_block = "10.0.2.0/24"

  display_name = "private-subnet"

  route_table_id = oci_core_route_table.private.id

  prohibit_public_ip_on_vnic = true
}