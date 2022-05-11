terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=4.4.0"
    }
  }
}


provider "aws" {
  region = "ap-southeast-2"
}


resource "random_string" "tfstatename" {
  length = 6
  special = false
  upper = false
}

resource "aws_s3_bucket" "kops_state" {
  bucket        = "bootcamp-kops-state-${random_string.tfstatename.result}"
  force_destroy = true

  tags = {
    Name = "kops remote state"
  }
}

resource "aws_s3_bucket" "tfrmstate" {
  bucket        = "bootcamp-tfstate-${random_string.tfstatename.result}"
  force_destroy = true

  tags = {
    Name = "TF remote state"
  }
}

resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "bootcamp-locktable-${random_string.tfstatename.result}"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_ecr_repository" "repository" {
  name                 = "bootcamp-container-repo"
  image_tag_mutability = "MUTABLE"
}

output "kops_state_bucket_name" {
  value = aws_s3_bucket.kops_state.bucket
}

output "tf_state_bucket" {
  value = aws_s3_bucket.tfrmstate.bucket
}

output "dynamoDb_lock_table_name" {
  value = aws_dynamodb_table.terraform_statelock.name
}


output "repository-url" {
  value = aws_ecr_repository.repository.repository_url
}

