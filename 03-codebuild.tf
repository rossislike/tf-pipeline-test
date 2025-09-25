

resource "aws_iam_role" "codebuild" {
  name = "${var.project_name}-codebuild-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "codebuild" {
  role = aws_iam_role.codebuild.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:ListBucket",
          "s3:DeleteBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.website.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.website.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.artifacts.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.artifacts.bucket}/*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_codebuild_project" "build" {
  name         = "${var.project_name}-build-${var.env}"
  description  = "Build project for ${var.project_name}"
  service_role = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.website.bucket
    }

    # environment_variable {
    #   name  = "CLOUDFRONT_DISTRIBUTION_ID"
    #   value = aws_cloudfront_distribution.distribution.id
    # }

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.env
    }
    # environment_variable {
    #   name  = "VITE_API_URL"
    #   # value = aws_apigatewayv2_api.photo_gallery.api_endpoint
    #   # value = "https://${aws_cloudfront_distribution.distribution.domain_name}"
    #   value = "https://photogallery.rumothy.com"
    # }

    # environment_variable {
    #   name  = "VITE_USER_POOL_ID"
    #   value = aws_cognito_user_pool.pool.id
    # }

    # environment_variable {
    #   name  = "VITE_CLIENT_ID"
    #   value = aws_cognito_user_pool_client.client.id
    # }
    # environment_variable {
    #   name  = "VITE_REDIRECT_URI"
    #   value = "https://photogallery.rumothy.com"
    # }
    # environment_variable {
    #   name  = "VITE_COGNITO_DOMAIN"
    #   value = "https://${aws_cognito_user_pool_domain.domain.domain}.auth.us-east-1.amazoncognito.com"
    # }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.artifacts.bucket}/cache"
  }

  tags = var.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/${aws_codebuild_project.build.name}"
  retention_in_days = 14

  tags = var.tags
}