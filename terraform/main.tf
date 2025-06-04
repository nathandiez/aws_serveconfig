# main.tf - AWS version that creates its own VPC

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Variable to control whether to run provisioners
variable "enable_local-exec" {
  description = "Whether to run the local-exec provisioners (IP detection and Ansible)"
  type        = bool
  default     = false
}

# AWS provider configuration
provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "nedv1-serveconfig-vpc"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "nedv1-serveconfig-igw"
  }
}

# Create subnet
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "nedv1-serveconfig-subnet"
  }
}

# Create route table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "nedv1-serveconfig-rt"
  }
}

# Associate route table with subnet
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Security group for the VM
resource "aws_security_group" "nedv1_serveconfig_sg" {
  name_prefix = "nedv1-serveconfig"
  vpc_id      = aws_vpc.main.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access for the config service
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nedv1-serveconfig-sg"
  }
}

module "nedv1-serveconfig-vm" {
  source = "./vm-module"
  vm_name        = "nedv1-serveconfig"
  security_group_id = aws_security_group.nedv1_serveconfig_sg.id
  subnet_id      = aws_subnet.main.id
}

# Wait for VM to get IP and be accessible
resource "time_sleep" "wait_for_vm" {
  depends_on = [module.nedv1-serveconfig-vm]
  create_duration = "60s"
}

# Run Ansible playbook after VM is ready (conditional)
resource "null_resource" "run_ansible" {
  count = var.enable_local-exec ? 1 : 0

  depends_on = [
    time_sleep.wait_for_vm
  ]

  triggers = {
    instance_id = module.nedv1-serveconfig-vm.instance_id
  }

  # Wait for SSH and update inventory
  provisioner "local-exec" {
    command = "./scripts/wait-for-ssh.sh"
  }

  # Run Ansible playbook
  provisioner "local-exec" {
    command = "./scripts/run-ansible.sh"
  }

  # Verify deployment
  provisioner "local-exec" {
    command = "./scripts/verify-deployment.sh"
  }
}

# Outputs
output "instance_id" {
  value = module.nedv1-serveconfig-vm.instance_id
  description = "AWS EC2 Instance ID"
}

output "vm_ip" {
  value = module.nedv1-serveconfig-vm.public_ip
  description = "VM IP address"
}

output "service_url" {
  value = "http://${module.nedv1-serveconfig-vm.public_ip}:5000"
  description = "Configuration service URL"
}

output "config_endpoint" {
  value = "http://${module.nedv1-serveconfig-vm.public_ip}:5000/pico_iot_config.json"
  description = "Configuration endpoint URL"
}
