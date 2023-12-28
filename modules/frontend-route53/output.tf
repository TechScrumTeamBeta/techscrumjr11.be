output "alias_name" {
    value = "www.${data.aws_route53_zone.route53.name}"
}