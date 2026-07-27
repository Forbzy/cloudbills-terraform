module "vpc" {

source = "terraform-aws-modules/vpc/aws"

version = "~>5.0"


name = "${var.cluster_name}-vpc"


cidr = "10.0.0.0/16"


azs = [
"eu-west-2a",
"eu-west-2b",
"eu-west-2c"
]


private_subnets = [
"10.0.1.0/24",
"10.0.2.0/24",
"10.0.3.0/24"
]


public_subnets = [
"10.0.101.0/24",
"10.0.102.0/24",
"10.0.103.0/24"
]


enable_nat_gateway = true

single_nat_gateway = false


enable_dns_hostnames = true


tags = {

Environment = "dev"

}
}