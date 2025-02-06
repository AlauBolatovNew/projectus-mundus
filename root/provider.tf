terraform {
  backend "s3" {
    bucket = "bolatovalau"
    key    = "development.terraform.tfstate"
    region = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.85"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}