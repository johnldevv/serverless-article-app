#!/bin/bash

set -e  # Stop on error

ENV_DIR="infra/environments/staging"

echo "🧨 Destroying AWS resources for staging environment..."

cd "${ENV_DIR}"
terraform destroy -auto-approve
cd - > /dev/null

echo "✅ Staging environment undeployed from AWS."
