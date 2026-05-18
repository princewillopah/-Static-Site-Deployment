variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
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

# variable "s3_bucket_name" {
#   description = "Name of the existing S3 bucket serving your static site"
#   type        = string
# }

# variable "cloudfront_distribution_id" {
#   description = "CloudFront distribution ID (e.g. E1A2B3C4D5E6F7)"
#   type        = string
# }