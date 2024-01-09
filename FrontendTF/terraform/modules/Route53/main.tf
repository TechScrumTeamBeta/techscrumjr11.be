
# data source to fetch hosted zone info from domain name:
data "aws_route53_zone" "hosted_zone" {
  name = var.hostzone_name
}





# creating A record for domain:
resource "aws_route53_record" "websiteurl" {
  name    = var.domain_name
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  type    = "A"
  alias {
    name                   = var.cloudfront.domain_name
    zone_id                = var.cloudfront.hosted_zone_id
    evaluate_target_health = true
  }
}


resource "aws_route53_record" "frontend-new-record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name = "*.techscrumjr11.com"
  type = "CNAME"
  ttl = 300

  records = [
    var.domain_name
  ]
}

