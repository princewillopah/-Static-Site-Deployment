# This file defines the CloudFront Origin Access Control (OAC) which allows CloudFront to securely access the S3 bucket without exposing it to the public.
# OAC is a newer and more secure alternative to Origin Access Identity (OAI) for S3 origins. It uses AWS Signature Version 4 for signing requests, providing better security and performance.
# The OAC is configured to always sign requests to the S3 origin, ensuring that only CloudFront can access the bucket contents. This is crucial for securing the static website hosted on S3.
# Without OAC, your bucket may become publicly accessible.


resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "${var.project_name}-oac"
  description                       = "Secure OAC for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}