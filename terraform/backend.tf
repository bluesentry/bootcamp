terraform {
  backend "remote" {
    organization = "bluesentry"

    workspaces {
      name = "bootcamp"
    }
  }
}