# terraform/vm-module/variables.tf - AWS version

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the VM"
  type        = map(string)
  default     = {
    "terraform-managed" = "true"
  }
}

variable "instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  default     = "t3.micro"  # Equivalent to 1 core, 1GB RAM
}

variable "security_group_id" {
  description = "Security group ID for the instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "ssh_username" {
  description = "Username for SSH access"
  type        = string
  default     = "ubuntu"  # Changed from "nathan" to standard Ubuntu default
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
