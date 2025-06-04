# terraform/vm-module/outputs.tf - AWS version

output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.vm.id
}

output "vm_name" {
  description = "Name of the VM"
  value       = aws_instance.vm.tags.Name
}

output "public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.vm.public_ip
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.vm.private_ip
}

output "public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.vm.public_dns
}
