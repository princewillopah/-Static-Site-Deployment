# ===============================================================
# GitHub OIDC Provider Configuration
# ===============================================================

# This file contains the OIDC provider configuration for GitHub Actions.
# It defines an IAM OpenID Connect provider that allows GitHub Actions to authenticate with AWS using OIDC tokens. 
# The provider is configured to trust the GitHub Actions OIDC endpoint, enabling secure authentication for deployments from GitHub Actions workflows.
# This setup is essential for enabling GitHub Actions to assume an IAM role in AWS and perform actions such as deploying to S3 or invalidating CloudFront distributions without the need for long-lived AWS credentials.
data "aws_iam_openid_connect_provider" "github" {
	  url = "https://token.actions.githubusercontent.com"
}

### The following resource block is commented out because the OIDC provider for GitHub Actions is already available in AWS and can be referenced using the data source above.
### the code below will create a new OIDC provider, which is not necessary and may cause confusion or conflicts. Instead, we can simply reference the existing provider using the data source.
# resource "aws_iam_openid_connect_provider" "github" {
#   url = "https://token.actions.githubusercontent.com"

#   client_id_list = [
#     "sts.amazonaws.com"
#   ]

#   thumbprint_list = [
#     "6938fd4d98bab03faadb97b34396831e3780aea1"
#   ]
# }

# =================================================
# IAM Role for GitHub Actions
# =================================================
# This file defines an IAM role that GitHub Actions can assume to perform deployments to AWS.
# The role is configured with a trust policy that allows GitHub Actions to authenticate using OIDC tokens from the GitHub Actions OIDC provider. 
# The trust policy includes conditions that restrict access to the role based on the audience and subject claims in the OIDC token, ensuring that only authorized GitHub repositories and branches can assume the role. 
# By using OIDC for authentication, we can securely allow GitHub Actions to interact with AWS services without the need for long-lived AWS credentials, enhancing the security of our deployment process.

resource "aws_iam_role" "github_actions" {
  name = "github-actions-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = data.aws_iam_openid_connect_provider.github.arn # Reference the existing OIDC provider for GitHub Actions using the data source
        }


        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
             "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:*" # "token.actions.githubusercontent.com:sub" = "repo:princewillopah/-Static-Site-Deployment:*"
          }
        }
      }
    ]
  })
}


# ================================================================
# IAM Policy for GitHub Actions Deployment
# ================================================================

resource "aws_iam_policy" "github_deploy_policy" {
  name = "github-deploy-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Sid    = "S3UploadAccess"
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]

        Resource = [
          aws_s3_bucket.website.arn,
          "${aws_s3_bucket.website.arn}/*"
        ]
      },

      {
        Sid    = "CloudFrontInvalidation"
        Effect = "Allow"

        Action = [
          "cloudfront:CreateInvalidation"
        ]

        Resource = "*"  # CloudFront invalidation permissions typically require access to all distributions, so we use "*" here. In a production environment, you may want to scope this down further if possible, like "arn:aws:cloudfront::${var.aws_account_id}:distribution/${var.cloudfront_distribution_id}"
      }
    ]
  })
}



# ================================================================
# Attach Policy to Role
# ================================================================


resource "aws_iam_role_policy_attachment" "github_deploy_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_deploy_policy.arn
}

# ============================================================
# Output the Role ARN for use in GitHub Actions workflows
# ============================================================

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

