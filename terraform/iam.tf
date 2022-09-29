resource "aws_iam_user" "this" {
  force_destroy = true
  name          = var.candidate_name
  tags          = local.tags
}

resource "aws_iam_group_membership" "this" {
  group = "sandbox-interviews"
  name  = "candidate_group_membership_for_${var.candidate_name}"
  users = [aws_iam_user.this.name]
}

resource "aws_iam_user_login_profile" "this" {
  user = aws_iam_user.this.name
}

resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}