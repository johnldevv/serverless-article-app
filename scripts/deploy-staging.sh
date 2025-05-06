#!/bin/bash

set -e  # Exit on error

DIST_DIR="dist"
ENV_DIR="infra/environments/staging"
LAMBDAS=("postArticle" "getArticles")

# Ensure dist directory exists
mkdir -p "${DIST_DIR}"

# Zip all Lambda functions
for LAMBDA_NAME in "${LAMBDAS[@]}"; do
  LAMBDA_SRC="api/${LAMBDA_NAME}"
  DIST_PATH="$(realpath ${DIST_DIR})/${LAMBDA_NAME}.zip"

  echo "📦 Preparing Lambda: ${LAMBDA_NAME}..."

  # Install runtime dependencies (excluding devDeps)
  cd "${LAMBDA_SRC}" || { echo "❌ Failed to cd into ${LAMBDA_SRC}"; exit 1; }
  echo "📦 Installing dependencies..."
  npm install --omit=dev

  # Force rebuild zip
  echo "🔁 Zipping code to ${DIST_PATH}..."
  rm -f "${DIST_PATH}"
  zip -r "${DIST_PATH}" . > /dev/null

  cd - > /dev/null
  echo "✅ Zipped ${LAMBDA_NAME} to ${DIST_PATH}"
done

# Deploy with Terraform
echo "🚀 Deploying staging environment to AWS..."
cd "${ENV_DIR}"
terraform init -input=false > /dev/null
terraform apply -auto-approve
cd - > /dev/null
echo "✅ Deployed Lambda functions + API Gateway to AWS (staging)"
