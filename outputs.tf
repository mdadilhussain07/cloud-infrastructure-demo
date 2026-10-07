output "vpc_id" {
  description = "The ID of the custom VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "ID of the Public Subnet"
  value       = module.networking.public_subnet_id
}

output "private_subnet_id" {
  description = "ID of the Private Subnet"
  value       = module.networking.private_subnet_id
}

output "instance_id" {
  description = "Zero-trust EC2 instance ID"
  value       = module.compute.instance_id
}

output "ssm_connect_command" {
  description = "Command to connect via SSM without open ports"
  value       = "aws ssm start-session --target ${module.compute.instance_id} --region ${var.aws_region}"
}
