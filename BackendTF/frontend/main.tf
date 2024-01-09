module "s3-policy" {
  source                     = "../../modules/s3-policy"
  S3_webhost_bucket          = var.S3_webhost_bucket
  cloudfront_distribution_id = module.cloudfront.cloudfront_distribution_id
  environment                = var.environment
  projectName                = var.projectName
}

module "s3" {
  source            = "../../modules/s3"
  S3_webhost_bucket = var.S3_webhost_bucket
  environment       = var.environment
  s3_OAC_policy     = module.s3-policy.s3_OAC_policy.json
}

module "acm" {
  source      = "../../modules/acm"
  root_domain = var.root_domain
}

module "cloudfront" {
  depends_on = [
    module.acm
  ]
  source                   = "../../modules/cloudfront"
  s3_regional_domain_name  = module.s3.s3_bucket.bucket_regional_domain_name
  root_domain              = var.root_domain
  frontend_certificate_arn = module.acm.frontend_certificate_arn
  environment              = var.environment
  region                   = var.region
  S3_webhost_bucket        = var.S3_webhost_bucket
  projectName              = var.projectName
}

module "route53" {
  source                       = "../../modules/frontend-route53"
  hosted_zone_name             = var.hosted_zone_name
  environment                  = var.environment
  cloudfront_distribution_name = module.cloudfront.cloudfront_distribution_name
  cloudfront_distribution_id   = module.cloudfront.cloudfront_distribution_id
}