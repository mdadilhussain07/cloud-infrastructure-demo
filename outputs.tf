output "vpc_id" {
  description = "The ID of the custom VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the Public Subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the Private Subnet"
  value       = aws_subnet.private.id
}

output "zero_trust_instance_id" {
  description = "EC2 Instance ID managed by SSM"
  value       = aws_instance.zero_trust_node.id
}

output "zero_trust_security_group_id" {
  description = "Security Group ID (Confirming 0 ingress rules)"
  value       = aws_security_group.private_sg.id
}

output "ssm_start_session_command" {
  description = "Command to connect securely via AWS Systems Manager without Port 22"
  value       = "aws ssm start-session --target ${aws_instance.zero_trust_node.id} --region ${var.aws_region}"
}