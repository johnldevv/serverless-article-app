#!/bin/bash

# Build postArticle Lambda
echo "Zipping postArticle Lambda..."
cd api/postArticle
zip -r ../../../dist/postArticle.zip . > /dev/null
cd - > /dev/null

echo "✅ Lambda zipped to dist/postArticle.zip"

# Step 2: Deploy to AWS via Terraform
echo "🚀 Deploying with Terraform..."
cd infra/environments/staging
terraform init -input=false > /dev/null
terraform apply -auto-approve
cd - > /dev/null

echo "✅ Lambda deployed to AWS (staging)."