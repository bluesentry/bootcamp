locals {
  candidate_username = replace(lower(var.candidate_name), " ", ".")
}
