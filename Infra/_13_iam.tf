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