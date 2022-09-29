locals {
  availability_zones = [
    data.aws_availability_zones.main.names[1],
  ]

  public_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 0),
  ]

  tags = {
    candidate = var.candidate_name
  }

  vpc_cidr = "10.201.0.0/20"
}

variable "build_windows_instance" {
  default     = false
  description = "set to true if windows instance is desired also"
}

variable "candidate_name" {
  default = "christopher.fulton"
}