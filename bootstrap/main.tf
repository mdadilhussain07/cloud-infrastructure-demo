terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"

  default_tags {
    tags = {
      Project     = "Cloud-Infrastructure-Showcase"
      ManagedBy   = "Terraform-Bootstrap"
      Environment = "Management"
    }
  }
}

# 1. Unique S3 Bucket for Terraform Remote State
resource "aws_s3_bucket" "terraform_state" {
  # Globally unique name: uses your AWS account ID as a suffix
  bucket = "adyl-tfstate-ap-south-1-755434486208"

  lifecycle {
    prevent_destroy = true
  }
}

# 2. State Versioning: Allows state recovery/rollback if corruption occurs
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Server-Side Encryption (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Strict Block on All Public Access
resource "aws_s3_bucket_public_access_block" "state_security" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 5. DynamoDB Table for Distributed State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "adyl-terraform-locks"
  billing_mode = "PAY_PER_REQUEST" # Free-tier compliant; zero charge when idle
  hash_key     = "LockID"         # Terraform requires this exact primary key

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Outputs for wiring the backend
output "s3_bucket_name" {
  description = "Remote state S3 bucket name"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_name" {
  description = "Remote state locking DynamoDB table name"
  value       = aws_dynamodb_table.terraform_locks.id
}
