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