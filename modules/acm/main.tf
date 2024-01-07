provider "aws" {
  alias   = "Virginia"
  region  = "us-east-1"
}

# Get frontend domain info
data "aws_acm_certificate" "frontend" {
  domain   = var.root_domain
  statuses = ["ISSUED"]
  provider = aws.Virginia
}