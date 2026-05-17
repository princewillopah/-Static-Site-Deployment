

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


