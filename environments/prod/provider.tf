terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "adyl-tfstate-ap-south-1-755434486208"
    key            = "showcase/prod/terraform.tfstate" # Dedicated PROD state key!
    region         = "ap-south-1"
    dynamodb_table = "adyl-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "CloudInfrastructureDemo"
    }
  }
}
