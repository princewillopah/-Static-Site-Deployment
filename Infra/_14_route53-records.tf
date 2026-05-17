###############################################################################
# Route 53 — DNS management for the domain and subdomain.
# =============================================================================
# Manages:
#   - Hosted zone lookup (assumes zone already exists in Route 53)
#      - if your domain is not registered in Route 53, you can create the zone here and update your registrar's NS records which is what we will do here
#   - A and AAAA alias records (apex + www) pointing to CloudFront
###############################################################################

# ---------------------------------------------------------------------------
# Hosted Zone — look up the existing hosted zone for the domain.
# If you need to CREATE the zone, replace this data source with:
#   resource "aws_route53_zone" "main" { name = var.domain_name }
# ---------------------------------------------------------------------------




resource "aws_route53_record" "root" {
  zone_id = data.terraform_remote_state.dns.outputs.hosted_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.terraform_remote_state.dns.outputs.hosted_zone_id
  name    = var.www_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}