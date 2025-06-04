terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Get the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "${var.vm_name}-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "vm" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type         = var.instance_type
  key_name              = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [var.security_group_id]
  subnet_id             = var.subnet_id
  monitoring = true
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    ssh_username = var.ssh_username
  }))
  tags = merge(var.tags, {
    Name = var.vm_name
  })
  associate_public_ip_address = true
}
