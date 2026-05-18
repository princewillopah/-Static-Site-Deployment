output "cloudfront_url" {
  value = aws_cloudfront_distribution.website.domain_name
}

output "website_bucket" {
  value = aws_s3_bucket.website.bucket
}

output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}

output "cloudfront_id" {
  value = aws_cloudfront_distribution.website.id
}

output "github_secrets_instructions" {
  description = "the instructions for setting up GitHub Secrets for OIDC authentication with AWS. This output provides a step-by-step guide on how to configure GitHub Actions to securely authenticate with AWS using OIDC tokens, allowing for seamless deployments from GitHub to AWS without the need for long-lived credentials."
  value       = <<EOT

# ── How to set up GitHub Secrets for OIDC authentication with AWS ──────────────────────────────────
#
# Step 1: Go to your repo: Settings → Secrets and variables → Actions → New repository secret
#
# Step 2: for name, enter: AWS_ROLE_ARN
# Step 3: for value, enter the ARN of the IAM role created by this Terraform configuration, which is: ${aws_iam_role.github_actions.arn}
# Do the same for the following secrets:
#   - Name: S3_BUCKET_NAME, Value: ${aws_s3_bucket.website.bucket}
#   - Name: CLOUDFRONT_DISTRIBUTION_ID, Value: ${aws_cloudfront_distribution.website.id}
#    
# After adding these secrets, your GitHub Actions workflows will be able to use them to authenticate with AWS and perform deployments securely using OIDC.
#
#
# Below are the name and value of the serets you need to add to GitHub:
#   - AWS_ROLE_ARN: ${aws_iam_role.github_actions.arn}
#   - S3_BUCKET_NAME: ${aws_s3_bucket.website.bucket}
#   - CLOUDFRONT_DISTRIBUTION_ID: ${aws_cloudfront_distribution.website.id}
# ─────────────────────────────────────────────────────────────────────────────
EOT
}