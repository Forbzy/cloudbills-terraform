module "networking" {

  source = "../../modules/networking"

  compartment_ocid = var.compartment_ocid

  region = var.region

  tags = local.tags
}

module "oke" {

  source = "../../modules/oke"

  compartment_ocid = var.compartment_ocid

  cluster_name = var.cluster_name

  kubernetes_version = var.kubernetes_version

  public_subnet_id = module.networking.public_subnet_id

  private_subnet_id = module.networking.private_subnet_id

  vcn_id = module.networking.vcn_id

  node_shape = var.node_shape

  node_count = var.node_count

  tags = local.tags
}

module "loadbalancer" {

  source = "../../modules/loadbalancer"

  compartment_ocid = var.compartment_ocid

  public_subnet_id = module.networking.public_subnet_id

  private_subnet_id = module.networking.private_subnet_id

  tags = local.tags
}