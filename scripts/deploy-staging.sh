#!/bin/bash

set -e  # Exit on error

LAMBDA_NAME="postArticle"
LAMBDA_SRC="api/${LAMBDA_NAME}"
DIST_DIR="dist"
DIST_PATH="$(realpath ${DIST_DIR})/${LAMBDA_NAME}.zip"
ENV_DIR="infra/environments/staging"

# Ensure dist/ directory exists
mkdir -p "${DIST_DIR}"

echo "📦 Zipping Lambda function: ${LAMBDA_NAME}..."
cd "${LAMBDA_SRC}"
zip -r "${DIST_PATH}" . > /dev/null
cd - > /dev/null
echo "✅ Zipped to ${DIST_PATH}"

echo "🚀 Deploying staging environment to AWS via Terraform..."
cd "${ENV_DIR}"
terraform init -input=false > /dev/null
terraform apply -auto-approve
cd - > /dev/null
echo "✅ Deployed Lambda + API Gateway to AWS (staging)"
