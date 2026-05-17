# AWS CloudFront Response Headers Policy for Security Headers
# This file defines a CloudFront Response Headers Policy that adds important security headers to all responses served by the CloudFront distribution. 
# The policy includes headers such as Content-Security-Policy, X-Content-Type-Options, X-Frame-Options, Referrer-Policy, Strict-Transport-Security, and X-XSS-Protection. 
# These headers help to protect the website from various web vulnerabilities and attacks, such as cross-site scripting (XSS), clickjacking, and MIME type sniffing. 
# By implementing this policy, we enhance the security posture of the static website hosted on S3 and served through CloudFront, ensuring that best practices for web security are followed.

resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${var.project_name}-security-headers"

  security_headers_config {

  content_security_policy {
    override = true

    content_security_policy = "default-src 'self'; script-src 'self' https://ajax.googleapis.com https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://use.fontawesome.com https://cdn.jsdelivr.net; font-src 'self' https://fonts.gstatic.com https://use.fontawesome.com; img-src 'self' data:;"
  }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }


    strict_transport_security {
      access_control_max_age_sec = 63072000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }

    xss_protection {
      protection = true
      mode_block = true
      override   = true
    }
  }
}

