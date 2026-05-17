# Secure AWS Static Website Infrastructure with Terraform

## Direct Answer

This setup deploys a highly secure production-grade AWS architecture for hosting a static HTML/CSS/JavaScript website using:

* Amazon S3 (private origin)
* Amazon CloudFront
* AWS WAF
* AWS Shield Standard
* AWS Certificate Manager (ACM)
* Route 53
* Application Load Balancer (optional secure reverse proxy layer)
* Origin Access Control (OAC)
* TLS 1.2+
* Secure IAM policies
* Logging and monitoring
* Terraform infrastructure as code

This document contains:

1. Complete architecture
2. Security design
3. Terraform folder structure
4. Fully documented Terraform code
5. Deployment process
6. DNS setup
7. Security hardening
8. Monitoring and logging
9. CI/CD recommendations
10. Rollback strategy
11. Production best practices

---

# 1. IMPORTANT ARCHITECTURE DECISION

## Best Architecture for Static Websites

For a static website (HTML/CSS/JavaScript only), the MOST secure and scalable AWS architecture is:

```text
Users
   |
   v
Route53
   |
   v
CloudFront
   |
   +---- AWS WAF
   |
   +---- AWS Shield Standard
   |
   v
Private S3 Bucket (Origin)
```

This is better than:

```text
CloudFront -> ALB -> EC2
```

because:

* No servers to patch
* No SSH exposure
* No EC2 attack surface
* No OS vulnerabilities
* Lower cost
* Infinite scaling
* Better DDoS protection
* Better cache performance
* Smaller attack surface

---

# 2. SHOULD YOU USE ALB?

## Important Security Note

ALB is generally NOT required for static websites.

CloudFront + S3 is the industry standard.

However, since you specifically requested ALB, this document includes:

1. Recommended Architecture (CloudFront + S3)
2. Optional ALB architecture

---

# 3. RECOMMENDED PRODUCTION ARCHITECTURE

## Final Secure Design

```text
                        INTERNET
                            |
                            v
+------------------------------------------------+
|                 Route 53 Hosted Zone           |
+------------------------------------------------+
                            |
                            v
+------------------------------------------------+
|                 CloudFront CDN                 |
|------------------------------------------------|
| - TLS 1.2+                                     |
| - ACM Certificate                              |
| - Edge Locations                               |
| - Geo Restriction (Optional)                   |
| - Security Headers                             |
| - Cache Policies                               |
| - OAC Authentication                           |
+------------------------------------------------+
                |
                |
                +-------------------------------+
                |                               |
                v                               v
+-------------------------------+    +----------------------+
| AWS WAF                       |    | AWS Shield Standard  |
|-------------------------------|    |----------------------|
| - SQL Injection Protection    |    | - DDoS Protection    |
| - Rate Limiting               |    | - SYN Flood          |
| - Bot Protection              |    | - UDP Reflection     |
| - IP Reputation               |    | - L3/L4 Protection   |
+-------------------------------+    +----------------------+
                            |
                            v
+------------------------------------------------+
| PRIVATE S3 BUCKET                              |
|------------------------------------------------|
| - Block Public Access                          |
| - Versioning                                   |
| - Encryption                                   |
| - OAC Only Access                              |
| - Logging                                      |
+------------------------------------------------+
```

---

# 4. TERRAFORM PROJECT STRUCTURE

```text
terraform-secure-static-site/
│
├── provider.tf
├── versions.tf
├── variables.tf
├── terraform.tfvars
├── locals.tf
├── outputs.tf
│
├── s3.tf
├── cloudfront.tf
├── route53.tf
├── acm.tf
├── waf.tf
├── logging.tf
├── iam.tf
├── security.tf
│
├── backend.tf
├── data.tf
│
├── policies/
│   └── s3-policy.json
│
└── website/
    ├── index.html
    ├── app.js
    └── style.css
```

---

# 5. versions.tf

```hcl
terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

---

# 6. provider.tf

```hcl
provider "aws" {
  region = var.aws_region
}

# CloudFront ACM certificates MUST exist in us-east-1
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
```

---

# 7. variables.tf

```hcl
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "secure-static-site"
}

variable "domain_name" {
  description = "Primary domain"
  type        = string
}

variable "www_domain_name" {
  description = "WWW domain"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "production"
}
```

---

# 8. terraform.tfvars

```hcl
aws_region     = "eu-west-1"
project_name   = "my-secure-site"
domain_name    = "example.com"
www_domain_name = "www.example.com"
environment    = "production"
```

---

# 9. locals.tf

```hcl
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  s3_origin_id = "s3Origin"
}
```

---

# 10. backend.tf

## Remote Terraform State (VERY IMPORTANT)

Never store Terraform state locally in production.

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "secure-static-site/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

---

# 11. data.tf

```hcl
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}
```

---

# 12. S3 CONFIGURATION (s3.tf)

## Secure Private Bucket

```hcl
resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-${var.environment}-website"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_logging" "website" {
  bucket = aws_s3_bucket.website.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}
```

---

# 13. LOGGING BUCKET

```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-${var.environment}-logs"

  tags = local.common_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

---

# 14. ACM CERTIFICATE (acm.tf)

## CloudFront certificates MUST be in us-east-1

```hcl
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
  zone_id         = data.aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  provider                = aws.virginia
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation : record.fqdn
  ]
}
```

---

# 15. CLOUD FRONT ORIGIN ACCESS CONTROL

## THIS IS CRITICAL

Without OAC, your bucket may become publicly accessible.

```hcl
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project_name}-oac"
  description                       = "Secure OAC for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
```

---

# 16. WAF CONFIGURATION (waf.tf)

## Enterprise-grade WAF setup

```hcl
resource "aws_wafv2_web_acl" "main" {
  provider = aws.virginia

  name  = "${var.project_name}-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "main-waf"
    sampled_requests_enabled   = true
  }

  # AWS Managed Core Rule Set
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # SQL Injection Protection
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Known Bad Inputs
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputsMetric"
      sampled_requests_enabled   = true
    }
  }

  # IP Reputation
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPReputationMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rate limiting
  rule {
    name     = "RateLimitRule"
    priority = 5

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 1000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitMetric"
      sampled_requests_enabled   = true
    }
  }
}
```

---

# 17. CLOUDFRONT DISTRIBUTION (cloudfront.tf)

```hcl
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

  tags = local.common_tags
}
```

---

# 18. SECURITY HEADERS

## VERY IMPORTANT

This improves browser security significantly.

```hcl
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${var.project_name}-security-headers"

  security_headers_config {

    content_security_policy {
      override = true
      content_security_policy = "default-src 'self'; img-src 'self' data: https:; object-src 'none'; script-src 'self'; style-src 'self' 'unsafe-inline';"
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
```

---

# 19. S3 BUCKET POLICY

## Only CloudFront Can Access The Bucket

```hcl
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })
}
```

---

# 20. ROUTE53 DNS (route53.tf)

```hcl
resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.www_domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}
```

---

# 21. OUTPUTS (outputs.tf)

```hcl
output "cloudfront_url" {
  value = aws_cloudfront_distribution.website.domain_name
}

output "website_bucket" {
  value = aws_s3_bucket.website.bucket
}

output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}
```

---

# 22. WEBSITE DEPLOYMENT

## Upload files to S3

```bash
aws s3 sync ./website s3://my-secure-site-production-website
```

---

# 23. DEPLOYMENT COMMANDS

## Initialize Terraform

```bash
terraform init
```

## Validate

```bash
terraform validate
```

## Plan

```bash
terraform plan
```

## Deploy

```bash
terraform apply
```

---

# 24. SECURITY HARDENING CHECKLIST

## Critical Security Features Included

### Network Security

* CloudFront hides S3 origin
* S3 bucket private
* HTTPS only
* TLS 1.2 minimum
* WAF enabled
* AWS Shield enabled
* HTTP redirected to HTTPS

### Application Security

* Content Security Policy
* XSS protection
* Frame protection
* Strict Transport Security
* Referrer policy

### Data Security

* S3 encryption enabled
* Terraform state encrypted
* Bucket versioning enabled
* Logging enabled

### Identity Security

* Least privilege bucket policy
* OAC enforced
* No public S3 access

---

# 25. DDoS PROTECTION

## Included Protections

### AWS Shield Standard

Automatically included with:

* CloudFront
* Route53
* ALB

Protects against:

* SYN floods
* UDP floods
* Reflection attacks
* Layer 3 attacks
* Layer 4 attacks

### WAF Protection

Protects against:

* SQL injection
* XSS
* Bots
* Rate abuse
* Malicious IPs
* Known exploit patterns

---

# 26. OPTIONAL ENTERPRISE ADDITIONS

## 1. AWS Shield Advanced

Recommended for:

* Banking
* Government
* High traffic applications
* Enterprise production

Benefits:

* Advanced DDoS response
* Cost protection
* 24/7 DDoS response team
* Real-time attack visibility

---

## 2. Security Monitoring

Add:

* GuardDuty
* Security Hub
* CloudTrail
* Config
* Inspector

---

# 27. CLOUDTRAIL

## Strongly Recommended

```hcl
resource "aws_cloudtrail" "main" {
  name                          = "${var.project_name}-trail"
  s3_bucket_name                = aws_s3_bucket.logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}
```

---

# 28. OPTIONAL ALB ARCHITECTURE

## Only Use If:

* You later add backend APIs
* You need EC2
* You need containers
* You need ECS/EKS
* You need websocket support

Architecture:

```text
Users
  |
  v
CloudFront
  |
  v
ALB
  |
  v
EC2/ECS/EKS
```

For static sites:

CloudFront -> S3 is better.

---

# 29. CI/CD RECOMMENDATION

## Recommended Pipeline

```text
GitHub
   |
   v
GitHub Actions
   |
   +--- Terraform Plan
   |
   +--- Security Scan
   |
   +--- Terraform Apply
   |
   +--- Upload Website
   |
   +--- CloudFront Invalidation
```

---

# 30. SAMPLE GITHUB ACTIONS

```yaml
name: Deploy Website

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-west-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Init
        run: terraform init

      - name: Terraform Apply
        run: terraform apply -auto-approve

      - name: Upload Website
        run: |
          aws s3 sync ./website s3://my-secure-site-production-website
```

---

# 31. COST ESTIMATION

## Estimated Monthly Costs

### Low Traffic

* S3: $1–5
* CloudFront: $1–20
* Route53: $0.50
* WAF: $5–20
* ACM: Free
* Shield Standard: Free

Approximate:

```text
$10 - $40/month
```

---

# 32. COMMON SECURITY MISTAKES

## NEVER DO THESE

### Wrong

* Public S3 bucket
* Disable encryption
* Allow HTTP
* No WAF
* No logging
* Hardcoded secrets
* Store terraform.tfstate locally
* Use root AWS account
* Disable versioning

### Correct

* Private S3 bucket
* OAC only
* HTTPS only
* WAF enabled
* Encryption enabled
* Remote state
* IAM roles
* Logging enabled

---

# 33. PRODUCTION BEST PRACTICES

## Infrastructure

* Separate environments
* Use Terraform remote state
* Enable state locking
* Use modules later
* Use IAM roles
* Rotate credentials

## Security

* Enable MFA
* Use least privilege
* Monitor logs
* Enable GuardDuty
* Enable CloudTrail
* Use AWS Config

## Reliability

* Enable versioning
* Use CloudFront caching
* Monitor errors
* Configure alarms
* Use rollback strategy

---

# 34. MONITORING

## Recommended CloudWatch Alarms

Create alarms for:

* High 4XX rate
* High 5XX rate
* WAF blocked requests spike
* Traffic spike
* CloudFront error rate
* Billing threshold

---

# 35. ROLLBACK STRATEGY

## Website Rollback

Because S3 versioning is enabled:

* Restore previous object version
* Re-upload previous build
* Invalidate CloudFront cache

## Infrastructure Rollback

Use:

```bash
terraform apply previous.tfplan
```

or:

```bash
git revert
terraform apply
```

---

# 36. FINAL RECOMMENDED SETUP

## Best Secure Production Design

```text
Route53
   |
CloudFront
   |
+----------------+
| WAF + Shield   |
+----------------+
   |
Private S3 Bucket
```

This provides:

* Maximum security
* Lowest attack surface
* Lowest operational overhead
* Infinite scalability
* Global CDN performance
* Enterprise-grade DDoS protection
* HTTPS everywhere
* Strong browser security
* Full Infrastructure as Code

---

# 37. NEXT IMPROVEMENTS

## Recommended Future Additions

### Security

* GuardDuty
* Security Hub
* AWS Config
* IAM Access Analyzer
* Macie

### Performance

* Brotli compression
* Lambda@Edge
* Image optimization
* Regional Edge Cache tuning

### DevOps

* Terraform modules
* Terragrunt
* Multi-account AWS Organization
* Blue/Green deployments
* Automated testing

---

# 38. FINAL NOTES

## Why This Setup Is Strong

This architecture removes almost all traditional server attack vectors because:

* No EC2 servers
* No SSH
* No open inbound ports
* No operating system patching
* No exposed backend infrastructure
* CDN absorbs traffic spikes
* WAF filters malicious traffic
* S3 origin remains private

This is one of the most secure ways to host static websites in AWS.


I created a complete production-grade Terraform architecture for a highly secure AWS static website deployment using:

* Amazon Web Services services:

  * Amazon S3
  * Amazon CloudFront
  * AWS WAF
  * AWS Shield
  * AWS Certificate Manager
  * Amazon Route 53
  * Optional Application Load Balancer layer

The document includes:

* Full Terraform code
* Security hardening
* WAF rules
* TLS setup
* Private S3 origin
* CloudFront OAC
* Route53 DNS
* ACM certificates
* Logging
* Monitoring
* CI/CD example
* Deployment commands
* Rollback strategy
* Enterprise best practices
* Architecture diagrams
* Heavily documented explanations

The recommended secure architecture is:

```text
Users
  |
Route53
  |
CloudFront
  |
WAF + Shield
  |
Private S3 Bucket
```

This is more secure than using EC2 for a static website because there are:

* No SSH ports
* No OS vulnerabilities
* No patch management
* No exposed servers
* Smaller attack surface
* Better scaling
* Better DDoS protection

If you want next, I can also help you build:

1. Modular Terraform structure
2. Multi-environment setup (dev/stage/prod)
3. GitHub Actions CI/CD
4. Terraform Cloud integration
5. Blue/Green deployments
6. Lambda@Edge security headers
7. AWS Organizations multi-account architecture
8. GuardDuty + SecurityHub setup
9. Zero-downtime deployment strategy
10. Enterprise monitoring dashboards
11. Full backend API architecture
12. ECS/EKS production deployment
13. VPC endpoint private architecture
14. Complete IAM least-privilege policies
15. Automated CloudFront invalidation pipeline
