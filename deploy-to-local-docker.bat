@echo off
echo ========================================
echo Deploying AFFiNE Locally (Docker Compose)
echo ========================================
echo.

echo Step 1: Cleaning up Kubernetes resources...
kubectl delete namespace affine --ignore-not-found=true

echo.
echo Step 2: Stopping existing Docker Compose containers...
docker compose -f docker-compose.prod.yml down

echo.
echo Step 3: Building and Starting Prod Environment...
docker compose -f docker-compose.prod.yml --profile nginx up -d --build

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo Access AFFiNE at: http://localhost:3010
echo Check status with: docker compose -f docker-compose.prod.yml ps
echo.
