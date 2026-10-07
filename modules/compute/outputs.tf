output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.zero_trust_node.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.zero_trust_sg.id
}
