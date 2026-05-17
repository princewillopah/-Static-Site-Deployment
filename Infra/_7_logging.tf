# AWS S3 Bucket for CloudFront Access Logs
# This file defines the S3 bucket that will be used to store access logs for the CloudFront distribution. 
# Access logging is an important feature that allows you to capture detailed information about every request made to your CloudFront distribution, including the requester's IP address, request time, HTTP method, and more. 
# By storing these logs in an S3 bucket, you can analyze them for security monitoring, troubleshooting, and gaining insights into your website traffic patterns. 
# The bucket is configured with server-side encryption for data protection and has public access blocked to ensure that the logs are securely stored and not accessible to unauthorized users.  




resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-${var.environment}-logs"

  tags = local.common_tags
}


resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudFrontLogs"
        Effect = "Allow"

        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.logs.arn}/cloudfront-logs/*"

        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}