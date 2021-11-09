module "iam_user" {
  source = "terraform-aws-modules/iam/aws//modules/iam-user"

  name = local.candidate_username

  create_iam_user_login_profile = true
  create_iam_access_key         = true
  password_reset_required       = false
  pgp_key                       = "keybase:${var.keybase_username}"
}

resource "aws_iam_user_policy_attachment" "ec2_full_control" {
  user       = module.iam_user.iam_user_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_user_policy_attachment" "vpc_full_control" {
  user       = module.iam_user.iam_user_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

resource "aws_iam_user_policy_attachment" "ssm_full_control" {
  user       = module.iam_user.iam_user_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
