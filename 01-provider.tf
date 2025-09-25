provider "aws" {
  region = "us-east-2"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.1"
    }
  }

  backend "s3" {
    bucket  = "rumo-state-bucket"
    key     = "rumotas-query/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

output "suffix" {
  value = local.suffix

}