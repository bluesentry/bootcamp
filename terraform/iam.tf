resource "aws_iam_access_key" "this" {
  for_each = local.pet_association

  user = aws_iam_user.this[each.key].name
}

resource "aws_iam_group_membership" "this" {
  for_each = local.pet_association

  group = "sandbox-interviews"
  name  = "candidate_group_membership_for_${each.key}"
  users = [aws_iam_user.this[each.key].name]
}

resource "aws_iam_user" "this" {
  for_each = local.pet_association

  force_destroy = true
  name          = each.key
  tags = {
    Provisioner = "Terraform"
  }
}

resource "aws_iam_user_login_profile" "this" {
  for_each = local.pet_association

  user = aws_iam_user.this[each.key].name
}

resource "random_pet" "this" {
  for_each = toset(var.candidate_names)
}