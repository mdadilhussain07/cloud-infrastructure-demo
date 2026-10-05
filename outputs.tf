output "vpc_id" {
  description = "The ID of the custom VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the Public Ingress Subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the Private Database Subnet"
  value       = aws_subnet.private.id
}

output "public_security_group_id" {
  description = "Security Group ID for Web Ingress"
  value       = aws_security_group.public_sg.id
}

output "private_security_group_id" {
  description = "Security Group ID for Private Database"
  value       = aws_security_group.private_sg.id
}
