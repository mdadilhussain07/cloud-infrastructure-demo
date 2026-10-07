variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "environment" {
  description = "Environment identifier"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the local public SSH key for break-glass administration"
  type        = string
  default     = "~/.ssh/id_showcase.pub"
}
