# infra/environments/staging/main.tf
variable "region" {
  default = "ap-southeast-1"
}

provider "aws" {
  region = var.region
}

# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy: Allow Lambda to access DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb_access" {
  name = "lambda-dynamodb-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Scan"
        ],
        Effect   = "Allow",
        Resource = aws_dynamodb_table.articles.arn
      }
    ]
  })
}

# DynamoDB Table for Articles
resource "aws_dynamodb_table" "articles" {
  name         = "articles-staging"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# Lambda: postArticle
resource "aws_lambda_function" "post_article" {
  function_name = "post-article-staging"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "${path.module}/../../../dist/postArticle.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../dist/postArticle.zip")
}

# API Gateway (HTTP API)
resource "aws_apigatewayv2_api" "articles_api" {
  name          = "articles-api-staging"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["http://localhost:5173"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
    expose_headers = ["Content-Type"]
    max_age = 3600
  }
}

# Integration: API Gateway → Lambda
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.articles_api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.post_article.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

# Route: POST /articles
resource "aws_apigatewayv2_route" "post_articles" {
  api_id    = aws_apigatewayv2_api.articles_api.id
  route_key = "POST /articles"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Deployment stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.articles_api.id
  name        = "staging"
  auto_deploy = true
}

# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "allow_apigw_invoke" {
  statement_id  = "AllowInvokeFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_article.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.articles_api.execution_arn}/*/*"
}

# get_articles
resource "aws_lambda_function" "get_articles" {
  function_name = "get-articles-staging"
  runtime       = "nodejs18.x"
  handler       = "index.handler"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "${path.module}/../../../dist/getArticles.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../dist/getArticles.zip")
}

resource "aws_apigatewayv2_integration" "get_articles_integration" {
  api_id                = aws_apigatewayv2_api.articles_api.id
  integration_type      = "AWS_PROXY"
  integration_uri       = aws_lambda_function.get_articles.invoke_arn
  integration_method    = "POST"
  payload_format_version = "2.0"
}

#Route: GET /articles
resource "aws_apigatewayv2_route" "get_articles_route" {
  api_id    = aws_apigatewayv2_api.articles_api.id
  route_key = "GET /articles"
  target    = "integrations/${aws_apigatewayv2_integration.get_articles_integration.id}"
}

#Permission for API Gateway to call Lambda
resource "aws_lambda_permission" "allow_apigw_invoke_get_articles" {
  statement_id  = "AllowInvokeFromAPIGatewayGetArticles"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_articles.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.articles_api.execution_arn}/*/*"
}

# S3 Bucket for Frontend (Staging)
resource "aws_s3_bucket" "frontend_staging" {
  bucket = "article-app-staging-frontend-jqcqy"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "frontend_staging" {
  bucket = aws_s3_bucket.frontend_staging.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Enable Static Website Hosting
resource "aws_s3_bucket_website_configuration" "frontend_staging" {
  bucket = aws_s3_bucket.frontend_staging.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html" # for SPA routing fallback
  }
}

# Public Read Policy (for website hosting — optional if using CloudFront later)
resource "aws_s3_bucket_policy" "frontend_staging_public" {
  bucket = aws_s3_bucket.frontend_staging.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.frontend_staging.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend_staging]
}

# Output S3 website URL
output "frontend_staging_site_url" {
  value = aws_s3_bucket_website_configuration.frontend_staging.website_endpoint
}

output "api_gateway_base_url" {
  value = "https://${aws_apigatewayv2_api.articles_api.id}.execute-api.${var.region}.amazonaws.com/${aws_apigatewayv2_stage.default.name}"
}
