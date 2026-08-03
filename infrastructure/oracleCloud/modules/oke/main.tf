resource "oci_containerengine_cluster" "oke_cluster" {

  compartment_id = var.compartment_ocid

  kubernetes_version = var.kubernetes_version

  name = var.cluster_name

  vcn_id = var.vcn_id

  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = var.public_subnet_id
  }

}

data "oci_containerengine_cluster_kube_config" "oke" {
  cluster_id = oci_containerengine_cluster.oke_cluster.id

  token_version = "2.0.0"
}

data "oci_containerengine_cluster" "oke" {
  cluster_id = oci_containerengine_cluster.oke_cluster.id
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}

data "oci_containerengine_node_pool_option" "options" {
  node_pool_option_id = "all"
  compartment_id      = var.compartment_ocid
}

resource "oci_containerengine_node_pool" "workers" {

  cluster_id = oci_containerengine_cluster.oke_cluster.id

  compartment_id = var.compartment_ocid

  kubernetes_version = var.kubernetes_version

  name = "${var.cluster_name}-workers"

  node_shape = var.node_shape

  node_config_details {

    size = var.node_count

    placement_configs {

      availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name

      subnet_id = var.private_subnet_id
    }
  }

  node_shape_config {

    ocpus = 1

    memory_in_gbs = 6
  }

  node_source_details {
    image_id                = "ocid1.image.oc1.uk-london-1.aaaaaaaaixdnqyiz7ivji5wrninhm4xfsnydkdr6arjkx6osjkn6byhh75ka"
    source_type             = "IMAGE"
    boot_volume_size_in_gbs = 50
  }
}
