terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 0.14"
}
provider "aws" {
  region     = "us-west-2"
  access_key = ""
  secret_key = ""
}
