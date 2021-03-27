locals {
  availability_zones = [
    data.aws_availability_zones.main.names[1],
  ]

  name = "bootcamp"

  public_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 0),
  ]

  vpc_cidr = "10.201.0.0/20"
}