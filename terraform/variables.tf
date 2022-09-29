locals {
  availability_zones = [
    data.aws_availability_zones.main.names[1],
  ]

  public_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 0),
  ]

  tags = {
    candidate   = var.candidate_name
    provisioner = "Terraform"
  }

  vpc_cidr = "10.201.0.0/20"
}

variable "candidate_name" {
  default = "christopher.fulton"
}