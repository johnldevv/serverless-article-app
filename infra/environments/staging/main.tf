# infra/environments/staging/main.tf
provider "aws" {
  region = "ap-southeast-1" # or your preferred region
}

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