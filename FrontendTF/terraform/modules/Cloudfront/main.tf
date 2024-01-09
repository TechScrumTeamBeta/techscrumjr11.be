#creating OAI :



# cloudfront terraform - creating AWS Cloudfront distribution :
resource "aws_cloudfront_distribution" "cf_dist" {
  enabled             = true
  aliases             = [var.domain_name,var.asterisk_domain_name]
  default_root_object = "index.html"
  origin {
    domain_name = var.input_s3_bucket.bucket_regional_domain_name
    origin_id   = var.input_s3_bucket.id #var.input_s3_bucket.id 
    s3_origin_config {
      origin_access_identity = var.oai-iam.cloudfront_access_identity_path
    }
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = var.input_s3_bucket.id
    viewer_protocol_policy = "redirect-to-https" # other options - https only, http
    forwarded_values {
      headers      = []
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["IN", "US", "CA","AU"]
    }
  }
  tags = {
    "Project"   = "lindalu.click"
    "ManagedBy" = "Terraform"
  }
  viewer_certificate {
    acm_certificate_arn      = var.input_acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }
}
