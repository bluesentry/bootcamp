output "public_ip" {
  value = aws_eip.this.public_ip
}

output "ssh_key" {
  value     = tls_private_key.default.private_key_pem
  sensitive = true
}