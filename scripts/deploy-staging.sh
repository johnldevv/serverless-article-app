#!/bin/bash

set -e  # Stop script on error

LAMBDA_NAME="postArticle"
DIST_PATH="dist/${LAMBDA_NAME}.zip"
LAMBDA_SRC="api/${LAMBDA_NAME}"
ENV_DIR="infra/environments/staging"

echo "📦 Zipping Lambda function: ${LAMBDA_NAME}..."
cd "${LAMBDA_SRC}"
zip -r "../../../${DIST_PATH}" . > /dev/null
cd - > /dev/null
echo "✅ Zipped to ${DIST_PATH}"

echo "🚀 Deploying to AWS (staging)..."
cd "${ENV_DIR}"
terraform init -input=false > /dev/null
terraform apply -auto-approve
cd - > /dev/null

echo "✅ Deployment complete: Lambda + API Gateway (staging)"
