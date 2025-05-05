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
