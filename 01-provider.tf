provider "aws" {
  region = "us-east-2"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.14.1"
    }
  }

  backend "s3" {
    bucket  = "rumotas-query-terraform" 
    key     = "rumotas-query/terraform.tfstate"    
    region  = "us-east-2"         
    encrypt = true                
  }
}


