module "route53_failover" {
  source                       = "../../../modules/route53_failover"
  hosted_zone_name             = var.hosted_zone_name
}