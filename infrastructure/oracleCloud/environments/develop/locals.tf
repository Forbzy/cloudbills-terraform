locals {

  environment = "dev"

  tags = {
    Project     = "CloudBills"
    Environment = local.environment
    Terraform   = "true"
  }

}