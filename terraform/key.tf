# Generate key
resource "tls_private_key" "default" {
  algorithm = "RSA"
}

# Add key to AWS
resource "aws_key_pair" "generated" {
  depends_on = [tls_private_key.default]
  key_name   = var.candidate_name
  public_key = tls_private_key.default.public_key_openssh
  tags       = local.tags
}