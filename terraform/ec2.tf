data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

data "aws_ami" "windows_2019" {
  most_recent = true
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon"]
}

module "instance_role" {
  for_each = local.pet_association
  source   = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  role_name = "${each.value}_instance_role"

  create_instance_profile = true
  create_role             = true
  custom_role_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  role_requires_mfa       = false
  trusted_role_services   = ["ec2.amazonaws.com"]
}

resource "aws_eip" "linux" {
  for_each = local.pet_association

  vpc = true

  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = each.value
  }
}

resource "aws_eip" "windows" {
  for_each = local.pet_association

  vpc = true
  tags = {
    Name = each.value
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "linux" {
  for_each = local.pet_association

  instance_id   = aws_instance.linux[each.key].id
  allocation_id = aws_eip.linux[each.key].id
}

resource "aws_eip_association" "windows" {
  for_each = local.pet_association

  instance_id   = aws_instance.windows[each.key].id
  allocation_id = aws_eip.windows[each.key].id
}

resource "aws_instance" "linux" {
  for_each = local.pet_association

  ami                     = data.aws_ami.linux.id
  disable_api_termination = false
  ebs_optimized           = true
  iam_instance_profile    = module.instance_role[each.key].iam_instance_profile_name
  instance_type           = "t3.small"
  key_name                = aws_key_pair.generated[each.key].key_name
  subnet_id               = module.vpc.public_subnets[0]

  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp3"
  }

  vpc_security_group_ids = [aws_security_group.linux[each.key].id]

  tags = {
    Name = "${each.value}_linux"
  }

  lifecycle {
    ignore_changes = [ami, user_data]
  }

  user_data = <<EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install git maven -y
  EOF
}

resource "aws_instance" "windows" {
  for_each = local.pet_association

  ami                     = data.aws_ami.windows_2019.id
  disable_api_termination = false
  ebs_optimized           = true
  iam_instance_profile    = module.instance_role[each.key].iam_instance_profile_name
  instance_type           = "t3.small"
  key_name                = aws_key_pair.generated[each.key].key_name
  subnet_id               = module.vpc.public_subnets[0]
  vpc_security_group_ids  = [aws_security_group.windows[each.key].id]

  root_block_device {
    encrypted   = true
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${each.value}_windows"
  }
}

resource "aws_security_group" "linux" {
  for_each = local.pet_association

  description = "sg_for_${each.value}_linux_instance"
  name        = "${each.value}_linux_sg"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = each.value
  }
}

resource "aws_security_group" "windows" {
  for_each = local.pet_association

  name        = "${each.value}_windows"
  vpc_id      = module.vpc.vpc_id
  description = "sg_for_${each.value}_windows_instance"

  tags = {
    Name = each.value
  }
}

resource "aws_security_group_rule" "linux_egress" {
  for_each = local.pet_association

  type        = "egress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
  description = "Do Not Modify This Rule"

  security_group_id = aws_security_group.linux[each.key].id
}

resource "aws_security_group_rule" "linux_ingress" {
  for_each = local.pet_association

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["8.8.8.8/32"]
  description = "Do Not Modify This Rule"

  security_group_id = aws_security_group.linux[each.key].id
}

resource "aws_security_group_rule" "windows_egress" {
  for_each = local.pet_association

  type        = "egress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.windows[each.key].id
}

resource "aws_security_group_rule" "windows_ingress" {
  for_each = local.pet_association

  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["8.8.8.8/32"]
  description = "Do Not Modify This Rule"

  security_group_id = aws_security_group.windows[each.key].id
}