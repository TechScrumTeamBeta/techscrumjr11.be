terraform {
  # backend "local" {

  # }
  backend "s3" {
    bucket = "techscrum-tfstate-bucket"
    key    = "frontend-prod-tfstate/terraform.tfstate"
    region = "ap-southeast-2"

    # Enable during Step-09     
    # For State Locking
    dynamodb_table = "techscrum-lock-table"
  }
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region     = "ap-southeast-2"
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}

provider "aws" {
  region = "us-east-1"
  alias = "us-east-1"
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}



# S3
module "s3" {
  source = "./modules/S3"
  oai-iam-arn = aws_cloudfront_origin_access_identity.oai.iam_arn
}

# Route53
module "route53" {
  source = "./modules/Route53"
  cloudfront = module.cloudfront.cloudfront
  providers = {
    aws = aws.us-east-1
  }
}


# Cloudfront
module "cloudfront" {
  source = "./modules/Cloudfront"
  input_s3_bucket = module.s3.bucket
  input_acm_certificate_arn = module.acm-cert.acm-cert-arn-asterisk
  oai-iam = aws_cloudfront_origin_access_identity.oai

}

# ACM
module "acm-cert" {
  source = "./modules/ACM"
  providers = {
    aws = aws.us-east-1
  }
}


# # Cloudwatch
module "cloudwatch" {
  source = "./modules/Cloudwatch"
  cloudfront-input = module.cloudfront.cloudfront

  providers = {
    aws = aws.us-east-1
  }

}



resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.domain_name}"
}