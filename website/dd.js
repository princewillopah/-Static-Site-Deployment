{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowS3StaticSiteDeploy",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::apple-static-site-bucket-001"
    },
    {
      "Sid": "AllowS3ObjectWriteDelete",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::apple-static-site-bucket-001/*"
    },
    {
      "Sid": "AllowCloudFrontInvalidation",
      "Effect": "Allow",
      "Action": "cloudfront:CreateInvalidation",
      "Resource": "arn:aws:cloudfront::016696895968:distribution/DISTRIBUTION_ID_HERE"
    }
  ]
}
