data "aws_route53_zone" "route53" {
  name    = var.hosted_zone_name
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.route53.id
  name    = var.environment == "uat" ? "uat-api.${data.aws_route53_zone.route53.name}" : "api.${data.aws_route53_zone.route53.name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}