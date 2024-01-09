
# generate ACM cert for domain :
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  # subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  # provider = var.aws_provider
  tags = {
    "Project"   = "www.techscrumjr11.com"
    "ManagedBy" = "Terraform"
  }
}


# validate cert:
resource "aws_route53_record" "certvalidation" {
  for_each = {
    for d in aws_acm_certificate.cert.domain_validation_options : d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "certvalidation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  # provider = aws.us-east-1
  validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
}

# data source to fetch hosted zone info from domain name:
data "aws_route53_zone" "hosted_zone" {
  name = var.hostzone_name
}



# create *.tecscrum.com certificate


# generate ACM cert for *.domain :
resource "aws_acm_certificate" "cert_asterisk" {
  domain_name               = var.asterisk_domain_name
  # subject_alternative_names = ["*.${var.asterisk_domain_name}"]
  validation_method         = "DNS"
  # provider = var.aws_provider

}


# validate cert:
resource "aws_route53_record" "certvalidation_asterisk_record" {
  for_each = {
    for d in aws_acm_certificate.cert_asterisk.domain_validation_options : d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "certvalidation_asterisk" {
  certificate_arn         = aws_acm_certificate.cert_asterisk.arn
  # provider = aws.us-east-1
  validation_record_fqdns = [for r in aws_route53_record.certvalidation_asterisk_record : r.fqdn]
}