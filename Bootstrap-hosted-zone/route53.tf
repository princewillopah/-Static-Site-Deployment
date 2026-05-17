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





# The hosted zone — this is the core resource.
# Route 53 will assign 4 nameservers to this zone automatically.
# you have to apply this block first, then go to your domain registrar and update the NS records to point to these nameservers before applying the rest of the configuration.
# If your domain is registered in Route 53, you can use the data source to look up the existing zone instead of creating a new one.
resource "aws_route53_zone" "primary" {
  name = var.domain_name

  # Optional: add tags for cost tracking and resource organization
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Purpose     = "primary-dns"
  }
}



