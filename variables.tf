variable "aws_region" {
  description = "Target AWS deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name tag"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "Primary CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public ingress subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the isolated database/internal subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "Compute instance sizing"
  type        = string
  default     = "t3.micro"
}
