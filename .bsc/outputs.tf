output "username" {
  value = module.iam_user.iam_user_name
}

output "password_decrypt_command" {
  value = module.iam_user.keybase_password_decrypt_command
}

output "aws_access_key_id" {
  value = module.iam_user.iam_access_key_id
}

output "secret_aws_access_key_decrypt_command" {
  value = module.iam_user.keybase_secret_key_decrypt_command
}
