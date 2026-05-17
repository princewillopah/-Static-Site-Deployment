# infra/variables.tf

variable "aws_account_id" {
  description = "Your 12-digit AWS account ID"
  type        = string
}

variable "github_org" {
  description = "Your GitHub username or organisation name"
  type        = string
}

variable "github_repo" {
  description = "Repository name (without the org prefix)"
  type        = string
}

variable "github_branch" {
  description = "Branch that is allowed to deploy"
  type        = string
  default     = "main"
}

variable "s3_bucket_name" {
  description = "Name of the existing S3 bucket serving your static site"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (e.g. E1A2B3C4D5E6F7)"
  type        = string
}

variable "deploy_role_name" {
  description = "Name for the IAM role GitHub Actions will assume"
  type        = string
  default     = "github-actions-deploy-role"
}

