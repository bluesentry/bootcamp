# Generate key
resource "tls_private_key" "default" {
  algorithm = "RSA"
}

# Add key to AWS
resource "aws_key_pair" "generated" {
  depends_on = [tls_private_key.default]
  key_name   = local.name
  public_key = tls_private_key.default.public_key_openssh
}

resource "random_string" "name" {
  length  = 4
  special = false
}
