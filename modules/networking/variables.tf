variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
}

variable "environment" {
  description = "Environment identifier (e.g., prod, dev)"
  type        = string
}
