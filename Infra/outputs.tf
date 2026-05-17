output "cloudfront_url" {
  value = aws_cloudfront_distribution.website.domain_name
}

output "website_bucket" {
  value = aws_s3_bucket.website.bucket
}

output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}