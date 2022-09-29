output "public_ip" {
  value = aws_eip.this.public_ip
}

output "ssh_key" {
  value     = tls_private_key.default.private_key_pem
  sensitive = true
}

output "iam_user" {
  value = aws_iam_user.this.name
}

output "iam_password" {
  value = aws_iam_user_login_profile.this.password
}