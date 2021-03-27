data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_eip" "this" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "this" {
  instance_id   = aws_instance.this.id
  allocation_id = aws_eip.this.id
}

resource "aws_instance" "this" {
  ami                     = data.aws_ami.this.id
  disable_api_termination = false
  ebs_optimized           = true
  instance_type           = t3.small
  key_name                = aws_key_pair.generated.key_name
  subnet_id               = module.vpc.public_subnets[0]

  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp3"
  }

  vpc_security_group_ids = aws_security_group.this.id

  tags = {
    Name = local.name
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

resource "aws_security_group" "this" {
  name        = local.name
  vpc_id      = module.vpc.vpc_id
  description = local.name
}

resource "aws_security_group_rule" "egress" {
  type        = "egress"
  protocol    = -1
  from_port   = 0
  to_port     = 0
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.this.id
}

resource "aws_security_group_rule" "ingress" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["8.8.8.8/32"]
  description = "Do Not Remove"

  security_group_id = aws_security_group.this.id
}