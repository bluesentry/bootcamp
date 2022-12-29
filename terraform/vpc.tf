data "aws_availability_zones" "main" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  azs            = local.availability_zones
  cidr           = local.vpc_cidr
  name           = "interview-vpc"
  public_subnets = local.public_subnets
  tags           = { Provisioner = "Terraform" }
}


output "subnets" {
  value = module.vpc.private_subnets
}