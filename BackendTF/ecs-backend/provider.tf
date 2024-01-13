terraform {
  # required_version = ">=0.12"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    //if you use multi aws account, add sahred-credentials_file and profile
    # shared_credentials_file = "~/.aws/credentials"
    # profile                 = "secondaccount"
    bucket = "techscrum-tfstate-leo"
    key    = "ecs-backedn/terraform.tfstate"
    # key    = "ecs-backend/${terraform.workspace}/terraform.tfstate"
    region = "ap-southeast-2"

     dynamodb_table = "techscrum-lock-table"
  }
}

provider "aws" {
  region = var.region
}

