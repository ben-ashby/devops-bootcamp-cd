terraform {
  backend "s3" {
    region = "ap-southeast-2"
  }
}

terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "=4.4.0"
    }
  }
}