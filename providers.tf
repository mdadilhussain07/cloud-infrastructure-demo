terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "adyl-tfstate-ap-south-1-755434486208"
    key            = "showcase/production/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "adyl-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Cloud-Infrastructure-Showcase"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}
