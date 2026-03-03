#!/bin/bash
# Builds the Docker image locally and pushes it to your AWS ECR

set -e

# Default variables
AWS_REGION="eu-north-1"
ECR_REPO_NAME="affine-backend"
IMAGE_TAG="latest"

echo "=== Locally Building & Pushing AFFiNE to ECR ==="

# 1. Get the AWS Account ID using your isolated aws-poco script
echo "Getting AWS Account ID..."
AWS_ACCOUNT_ID=$(aws-poco sts get-caller-identity --query Account --output text | grep -oE "[0-9]{12}")
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Target Registry: $ECR_REGISTRY/$ECR_REPO_NAME"

# 2. Login to ECR via Docker using aws-poco
echo "Logging into ECR..."
aws-poco ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

# 3. Build the Docker Image
echo "Building the Docker image..."
docker build -t $ECR_REPO_NAME:$IMAGE_TAG -f Dockerfile.prod .

# 4. Tag the Image
echo "Tagging the image..."
docker tag $ECR_REPO_NAME:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPO_NAME:$IMAGE_TAG

# 5. Push the Image
echo "Pushing the image to ECR..."
docker push $ECR_REGISTRY/$ECR_REPO_NAME:$IMAGE_TAG

echo "=== Done! Image pushed successfully. ==="
