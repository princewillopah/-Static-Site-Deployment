terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Store state remotely — required for any real project
  backend "s3" {
    bucket         = "remote-state-backend-bucket"
    key            = "github/oidc/static-sites/terraform.tfstate"
    region         = "us-east-1" # note that Terraform backend blocks do not allow variables. The region must be hardcoded or passed through backend config.
    dynamodb_table = "terraform-locks"
    encrypt        = true
}
}


provider "aws" {
  region = "us-east-1"
}