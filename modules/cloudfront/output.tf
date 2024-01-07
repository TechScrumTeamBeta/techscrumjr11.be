output "cloudfront_distribution_id" {
    value = aws_cloudfront_distribution.frontend.hosted_zone_id
}

output "cloudfront_distribution_name" {
   value = aws_cloudfront_distribution.frontend.domain_name
}