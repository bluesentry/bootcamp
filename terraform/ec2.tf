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
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  role_name = "${var.candidate_name}_instance_role"

  create_instance_profile = true
  create_role             = true
  custom_role_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  role_requires_mfa       = false
  trusted_role_services   = ["ec2.amazonaws.com"]
}

resource "aws_eip" "linux" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
  tags = local.tags
}

resource "aws_eip_association" "this" {
  instance_id   = aws_instance.linux.id
  allocation_id = aws_eip.linux.id
}

resource "aws_instance" "linux" {
  ami                     = data.aws_ami.linux.id
  disable_api_termination = false
  ebs_optimized           = true
  iam_instance_profile    = module.instance_role.iam_instance_profile_name
  instance_type           = "t3.small"
  key_name                = aws_key_pair.generated.key_name
  subnet_id               = module.vpc.public_subnets[0]

  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp3"
  }

  vpc_security_group_ids = [aws_security_group.linux.id]

  tags = merge(local.tags, {
    Name = "${var.candidate_name}_linux"
  })

  lifecycle {
    ignore_changes = [ami, user_data]
  }

  user_data = <<EOF
  #!/bin/bash
  sudo yum update -y
  sudo yum install git maven -y
  EOF
}

resource "aws_eip" "windows" {
  count = var.build_windows_instance ? 1 : 0

  vpc  = true
  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "windows" {
  count = var.build_windows_instance ? 1 : 0

  instance_id   = aws_instance.windows.id
  allocation_id = aws_eip.windows.id
}

resource "aws_instance" "windows" {
  count = var.build_windows_instance ? 1 : 0

  ami                     = data.aws_ami.windows_2019.id
  disable_api_termination = false
  ebs_optimized           = true
  iam_instance_profile    = module.instance_role.iam_instance_profile_name
  instance_type           = "t3.small"
  key_name                = aws_key_pair.generated.key_name
  subnet_id               = module.vpc.public_subnets[0]
  vpc_security_group_ids  = [aws_security_group.windows.id]

  root_block_device {
    encrypted   = true
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.candidate_name}_windows"
  }
}

resource "aws_security_group" "linux" {
  description = "sg_for_${var.candidate_name}_linux_instance"
  name        = "${var.candidate_name}_linux_sg"
  tags        = local.tags
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "linux_egress" {
  type        = "egress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]
  description = "Do Not Modify This Rule"

  security_group_id = aws_security_group.linux.id
}

resource "aws_security_group_rule" "linux_ingress" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["8.8.8.8/32"]
  description = "Do Not Modify This Rule"

  security_group_id = aws_security_group.linux.id
}

resource "aws_security_group" "windows" {
  count = var.build_windows_instance ? 1 : 0

  name        = "${var.candidate_name}_windows"
  vpc_id      = module.vpc.vpc_id
  description = "sg_for_${var.candidate_name}_windows_instance"
}

resource "aws_security_group_rule" "windows_egress" {
  count = var.build_windows_instance ? 1 : 0

  type        = "egress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.windows.id
}

resource "aws_security_group_rule" "windows_ingress" {
  count = var.build_windows_instance ? 1 : 0
  
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["8.8.8.8/32"]
  description = "Do Not Modify This Rule"

  security_group_id = aws_security_group.windows.id
}

