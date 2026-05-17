terraform {
  backend "s3" {
    bucket         = "remote-state-backend-bucket"
    key            = "bootstrap-dns/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}