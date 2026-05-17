provider "aws" {
  region = var.aws_region
}

# CloudFront ACM certificates MUST exist in us-east-1
provider "aws" {
  alias  = "virginia"
  region = "us-east-1" # irrespective of the region you choose above, this "us-east-1" is required for CloudFront ACM certificates
}