#######################################
# Networking Module
#######################################

resource "oci_core_virtual_network" "vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "oke-vcn"
  cidr_block     = "10.0.0.0/16"
  dns_label      = "okevcn"
}

#######################################
# Internet Gateway
#######################################

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "oke-igw"
  enabled        = true
}

#######################################
# NAT Gateway
#######################################

resource "oci_core_nat_gateway" "nat" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "oke-nat"
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
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "oke-service-gateway"

  services {
    service_id = data.oci_core_services.services.services[0].id
  }
}

#######################################
# Public Route Table
#######################################

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "public-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

#######################################
# Private Route Table
#######################################

resource "oci_core_route_table" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "private-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat.id
  }

  route_rules {
    destination       = data.oci_core_services.services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.sgw.id
  }
}

#######################################
# Public Subnet
#######################################

resource "oci_core_subnet" "public_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "public-subnet"
  route_table_id             = oci_core_route_table.public.id
  prohibit_public_ip_on_vnic = false

  # Fixed: Linked to security list safely now that dependency loop is removed
  security_list_ids          = [oci_core_security_list.worker_security_list.id]
}

#######################################
# Private Subnet
#######################################

resource "oci_core_subnet" "private_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_virtual_network.vcn.id
  cidr_block                 = "10.0.2.0/24"
  display_name               = "private-subnet"
  route_table_id             = oci_core_route_table.private.id
  prohibit_public_ip_on_vnic = true

  security_list_ids          = [oci_core_security_list.worker_security_list.id]
}

#######################################
# Worker Security List
#######################################

resource "oci_core_security_list" "worker_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "oke-worker-security-list"

  # Existing Ingress: SSH
  ingress_security_rules {
    protocol    = "6" 
    source      = "0.0.0.0/0"
    stateless   = false
    description = "TCP traffic for ports: 22 SSH Remote Login Protocol"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # Existing Ingress: ICMP Type 3, 4
  ingress_security_rules {
    protocol    = "1" 
    source      = "0.0.0.0/0"
    stateless   = false
    description = "ICMP traffic for: 3, 4 Destination Unreachable"

    icmp_options {
      type = 3
      code = 4
    }
  }

  # Existing Ingress: ICMP Type 3 (Internal VCN)
  ingress_security_rules {
    protocol    = "1" 
    source      = "10.0.0.0/16"
    stateless   = false
    description = "ICMP traffic for: 3 Destination Unreachable"

    icmp_options {
      type = 3
    }
  }

  # Existing Egress: All traffic allowed
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
    stateless   = false
    description = "All traffic for all ports"
  }

  # Missing Ingress: Internal Node-to-Node Communication
  ingress_security_rules {
    protocol    = "all"
    source      = "10.0.0.0/16" 
    stateless   = false
    description = "Allow all protocols between worker nodes"
  }

  # Missing Ingress: Control Plane Kubelet Management
  ingress_security_rules {
    protocol    = "6" 
    source      = "10.0.1.0/24" # Fixed: Explicit string avoids Terraform cycle loops   
    stateless   = false
    description = "OKE Control Plane to worker Kubelet/management ports"

    tcp_options {
      min = 10250
      max = 10256
    }
  }

  # Missing Ingress: Control Plane to Node Webhooks (All Ports)
  ingress_security_rules {
    protocol    = "6" 
    source      = "10.0.1.0/24" # Fixed: Explicit string avoids Terraform cycle loops   
    stateless   = false
    description = "Control plane to worker node webhook communication"

    tcp_options {
      min = 1025
      max = 65535
    }
  }
  # Ingress: Allow Bastion/Public Subnet to reach Kubernetes API Endpoint
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "10.0.1.0/24" # Your Public Subnet CIDR block
    stateless   = false
    description = "Allow OCI Bastion to communicate with Kubernetes API Server"

    tcp_options {
      min = 6443
      max = 6443
    }
  }
}

resource "oci_bastion_bastion" "flux_bastion" {
  bastion_type                 = "STANDARD"
  compartment_id               = var.compartment_ocid
  target_subnet_id             = oci_core_subnet.public_subnet.id
  client_cidr_block_allow_list = ["0.0.0.0/0"] # For production, restrict this to your public IP
  name                         = "flux-bootstrap-bastion"
  max_session_ttl_in_seconds   = 10800
}