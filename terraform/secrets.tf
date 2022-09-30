resource "aws_secretsmanager_secret" "this" {
  for_each = local.pet_association

  name        = "${each.key}-credentials"
  description = "Credentials for ${each.key}"
}

resource "aws_secretsmanager_secret_version" "this" {
  for_each = local.pet_association

  secret_id = aws_secretsmanager_secret.this[each.key].id

  secret_string = trim(jsonencode(flatten([
    for name, random_pet in local.pet_association : [
      for username, password in aws_iam_user_login_profile.this : [
        for key, secret_values in aws_iam_access_key.this : [
          for k, v in tls_private_key.default : {
            username          = username
            pet_association   = random_pet
            access_key_id     = secret_values.id
            secret_access_key = secret_values.secret
            ssh_key           = v.private_key_pem
          } if k == each.key
        ] if key == each.key
      ] if username == each.key
    ] if name == each.key
  ])), "[]")
}
