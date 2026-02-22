@echo off
echo ========================================
echo Deploying AFFiNE to Local Kubernetes (Docker Desktop)
echo ========================================
echo.

echo Step 1: verifying Docker Desktop is running...
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker is not running!
    exit /b 1
)

echo.
echo Step 1.5: Building Docker Image (Local)...
echo Skipping build for now as requested (assuming image exists or built previously).
rem docker build -t pelvity/affine-backend:prod -f Dockerfile.prod .
rem if %ERRORLEVEL% NEQ 0 (
rem     echo ERROR: Build failed.
rem     exit /b 1
rem )

echo.
echo Step 2: Applying Kubernetes manifests...
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/redis.yaml
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/affine.yaml

echo.
echo Step 2.5: Restarting deployment to pick up new image...
kubectl rollout restart deployment/affine -n affine

echo.
echo Step 3: Waiting for deployment...
kubectl rollout status deployment/affine -n affine --timeout=90s

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo Access AFFiNE at: http://localhost:30010
echo Check pods with: kubectl get pods -n affine
echo.
