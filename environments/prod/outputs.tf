output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_id" {
  value = module.networking.public_subnet_id
}

output "private_subnet_id" {
  value = module.networking.private_subnet_id
}

output "instance_id" {
  value = module.compute.instance_id
}

output "ssm_connect_command" {
  value = "aws ssm start-session --target ${module.compute.instance_id} --region ${var.aws_region}"
}
