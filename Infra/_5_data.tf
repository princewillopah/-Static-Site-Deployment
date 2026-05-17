# data "aws_route53_zone" "main" {
#   name         = var.domain_name
#   private_zone = false
# }

# this is the same as above but with remote state data source
# Load outputs from another Terraform state "bootstrap-dns/terraform.tfstate" stored in S3
data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
      bucket = "remote-state-backend-bucket"
      key    = "bootstrap-dns/terraform.tfstate"
      region = "us-east-1"
    }
}

