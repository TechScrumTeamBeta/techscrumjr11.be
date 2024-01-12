terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  # shared_credentials_file = "~/.aws/credentials"
  # profile                 = "secondaccount"
  region = var.aws_region
}

terraform {
  backend "s3" {
    //if you use multi aws account, add sahred-credentials_file and profile
    # shared_credentials_file = "~/.aws/credentials"
    # profile                 = "secondaccount"
    bucket = "techscrum-tfstate-bucket"
    key    = "opensearch_and_monitor/terraform.tfstate"
    region = "ap-southeast-2"

    # Enable during Step-09     
    # For State Locking
    dynamodb_table = "techscrum-lock-table"
  }
}


module "lambda_role_module" {
  source = "./modules/lambda_role"
}

module "opensearch_cluster" {
  source              = "./modules/opensearch_cluster"
  masteruser_name     = var.masteruser_name
  masteruser_password = var.masteruser_password
  domain_name         = var.domain_name
}

module "log_subscription_filter" {
  source               = "./modules/log_subscription_filter"
  app_name             = var.app_name
  app_environment_uat  = var.app_environment_uat
  app_environment_prod = var.app_environment_prod
  role_arn             = module.lambda_role_module.role_arn
  OPENSEARCH_ENDPOINT  = module.opensearch_cluster.OPENSEARCH_ENDPOINT
}

module "vpc_and_sg" {
  source             = "./modules/vpc_and_sg" // path to your module
  vpc_cidr_block     = var.vpc_cidr_block
  public_subnets     = var.public_subnets
  availability_zones = var.availability_zones
}

module "ec2_prometheus_yace_grafana" {
  source        = "./modules/ec2_prometheus_yace_grafana" // path to your module
  subnet_id     = module.vpc_and_sg.subnet_id
  monitor_sg_id = module.vpc_and_sg.monitor_sg_id
}
