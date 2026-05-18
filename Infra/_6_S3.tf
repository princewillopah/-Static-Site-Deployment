

resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-${var.environment}-website"

  tags = local.common_tags
}

# Versioning — allows recovery of accidentally overwritten or deleted files
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id

  versioning_configuration {
    status = "Enabled"
  }
}
# Server-side encryption — AES-256 by default, KMS if key provided
resource "aws_s3_bucket_server_side_encryption_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
# Block ALL public access — CloudFront accesses via OAC, not public URLs
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# Access logging — all S3 requests logged to the log bucket with prefix for easier analysis
resource "aws_s3_bucket_logging" "website" {
  bucket = aws_s3_bucket.website.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}


///////////////////////////////////////////////////////////
///////// Logs Bucket ////////////////////////////////////
///////////////////////////////////////////////////////////


# AWS S3 Bucket Policy for CloudFront Access
# This file defines the S3 bucket policy that allows CloudFront to access the S3 bucket securely using the Origin Access Control (OAC). 
# The policy grants the CloudFront service principal permission to perform the s3:GetObject action on the bucket, but only when the request originates from the specific CloudFront distribution. 
# This ensures that the S3 bucket is not publicly accessible and can only be accessed through the CloudFront distribution, enhancing the security of the static website hosted on S3. 
# By implementing this bucket policy, we prevent unauthorized access to the S3 bucket and ensure that all traffic to the bucket is routed through CloudFront, allowing us to leverage CloudFront's security features and performance optimizations.

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })
}




///////////////////////////////////////////////////////////
///////// Logs Bucket ////////////////////////////////////
///////////////////////////////////////////////////////////



# resource "aws_s3_bucket" "logs" {
#   bucket = "${var.project_name}-${var.environment}-logs"

#   tags = local.common_tags
# }

# resource "aws_s3_bucket_ownership_controls" "logs" {
#   bucket = aws_s3_bucket.logs.id

#   rule {
#     object_ownership = "BucketOwnerPreferred"
#   }
# }

# resource "aws_s3_bucket_acl" "logs" {
#   depends_on = [
#     aws_s3_bucket_ownership_controls.logs
#   ]

#   bucket = aws_s3_bucket.logs.id
#   acl    = "log-delivery-write"
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
#   bucket = aws_s3_bucket.logs.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# resource "aws_s3_bucket_public_access_block" "logs" {
#   bucket = aws_s3_bucket.logs.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }


