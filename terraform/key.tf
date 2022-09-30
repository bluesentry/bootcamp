# Generate key
resource "tls_private_key" "default" {
  for_each = local.pet_association

  algorithm = "RSA"
}

# Add key to AWS
resource "aws_key_pair" "generated" {
  for_each = local.pet_association

  depends_on = [tls_private_key.default]
  key_name   = each.value
  public_key = tls_private_key.default[each.key].public_key_openssh
  tags       = {
    Name = each.value
  }
}