data "aws_availability_zones" "main" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  azs                = local.availability_zones
  cidr               = local.vpc_cidr
  enable_s3_endpoint = true
  name               = local.name
  public_subnets     = local.public_subnets
}