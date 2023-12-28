locals {
  s3_origin_id = "techscrumOrigin"
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.S3_webhost_bucket}.s3.${var.region}.amazonaws.com"
  description                       = "S3 OAC"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Create cloudfront distribution
resource "aws_cloudfront_distribution" "frontend" {
  origin {
    domain_name              = var.s3_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  aliases = [var.environment == "uat" ? "${var.environment}.${var.root_domain}" : "${var.root_domain}"]

  enabled             = true
  is_ipv6_enabled     = false
  comment             = var.projectName
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress               = true
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
    acm_certificate_arn      = var.frontend_certificate_arn
  }

  tags = {
    Name = var.environment
  }
}
