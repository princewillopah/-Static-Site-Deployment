# AWS CloudFront distribution for the static website
# This file defines the CloudFront distribution that serves the static website content from the S3 bucket. 
# The distribution is configured with an Origin Access Control (OAC) to securely access the S3 bucket without exposing it to the public. 
# It also includes a custom cache behavior that allows only GET and HEAD requests, and redirects HTTP to HTTPS for secure access. 
# The distribution uses the ACM certificate for SSL/TLS encryption and is associated with the AWS WAFv2 Web ACL for enhanced security. 
# Access logging is enabled to capture all requests to the distribution, with logs stored in the designated S3 bucket for analysis and monitoring.

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  aliases = [
    var.domain_name,
    var.www_domain_name
  ]

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.s3_origin_id
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"

    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  web_acl_id = aws_wafv2_web_acl.main.arn

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_domain_name
    prefix          = "cloudfront-logs/"
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }
  
  tags = local.common_tags
}

