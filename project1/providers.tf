terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.18.0"
    }
  }
  # backend "s3" {
  # bucket = "s3-for-noobs401"
  # key = "terraform.tfstate"
  # region = "ap-southeast-2"
  # use_lockfile = true

  # }
}

provider "aws" {
  region = "ap-southeast-2"
}
