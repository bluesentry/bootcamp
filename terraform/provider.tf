terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0,!= 3.14.0"
    }
  }
  required_version = ">= 0.14"
}
provider "aws" {
  region = "us-east-1"
  access_key = ""
  secret_key = ""
}