#!/bin/bash
# This script is intended to be run ON the EC2 instance
# It pulls the latest image from ECR and restarts the container

set -e

AWS_REGION="eu-north-1"
ECR_REPO_NAME="affine-backend"
IMAGE_TAG="latest"

# 1. Get Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "=== Deploying AFFiNE from ECR Registry: $ECR_REGISTRY ==="

# 2. Login to ECR
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

# 3. Pull latest image
echo "Pulling $ECR_REGISTRY/$ECR_REPO_NAME:$IMAGE_TAG..."
docker pull "$ECR_REGISTRY/$ECR_REPO_NAME:$IMAGE_TAG"

# 4. Stop and remove existing container (if any)
echo "Cleaning up old containers..."
docker stop affine-app || true
docker rm affine-app || true

# 5. Run new container
# Note: In production, we should use docker-compose and .env files.
# For the first manual run, we'll use docker run to verify connectivity.
echo "Starting new container..."
docker run -d \
  --name affine-app \
  --restart always \
  -p 3010:3010 \
  -v affine_data:/app/data \
  -e NODE_ENV=production \
  -e PORT=3010 \
  "$ECR_REGISTRY/$ECR_REPO_NAME:$IMAGE_TAG"

echo "=== Deployment successful! ==="
docker ps
