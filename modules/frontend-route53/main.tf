data "aws_route53_zone" "route53" {
  name    = var.hosted_zone_name
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.route53.id
  name    = var.environment == "uat" ? "uat.${data.aws_route53_zone.route53.name}" : "www.${data.aws_route53_zone.route53.name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_distribution_name
    zone_id                = var.cloudfront_distribution_id
    evaluate_target_health = true
  }
}