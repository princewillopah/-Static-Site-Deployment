variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}



variable "domain_name" {
  description = "Primary domain"
  type        = string
}



variable "environment" {
  description = "Environment"
  type        = string
  default     = "production"
}