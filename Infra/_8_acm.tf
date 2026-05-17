# This file defines the ACM certificate and its DNS validation records for the CloudFront distribution.
# The certificate is created in us-east-1 because CloudFront requires certificates to be in that region.

resource "aws_acm_certificate" "cert" {
  provider          = aws.virginia
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = [
    var.www_domain_name
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = local.common_tags
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.terraform_remote_state.dns.outputs.hosted_zone_id  # assumes hosted zone already exists in Route 53, if not, create it here and update your registrar's NS records
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}

//////////////////////////////////////////////////////////
