terraform {
  backend "s3" {
    bucket         = "remote-state-backend-bucket"
    key            = "task-one-infrastructure/terraform.tfstate"
    region         = "us-east-1" # note that Terraform backend blocks do not allow variables. The region must be hardcoded or passed through backend config.
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}