locals {
  availability_zones = [
    data.aws_availability_zones.main.names[1],
  ]

  pet_association = {
    for k, v in random_pet.this : k => v.id
  }

  public_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 0),
  ]

  vpc_cidr = "10.201.0.0/20"
}

variable "candidate_names" {
  default = []
  description = "list of candidate names, lower case, formatted as firstname.lastname"
  type        = list(string)
}