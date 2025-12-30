@echo off
echo ========================================
echo Building and Deploying AFFiNE to Kubernetes (k3s)
echo ========================================
echo.

echo Step 1: Building Docker image...
docker build -t pelvity/affine-backend:prod -f Dockerfile.prod .

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker build failed!
    
    exit /b 1
)

echo.
echo Step 2: Saving image to tar file...
docker save pelvity/affine-backend:prod -o affine-backend-prod.tar

echo.
echo Step 3: Compressing...
tar -czf affine-backend-prod.tar.gz affine-backend-prod.tar

echo.
echo Step 4: Copying image to EC2 (aws-kacperjakub2099)...
scp affine-backend-prod.tar.gz aws-kacperjakub2099:~/

echo.
echo Step 5: Importing image into k3s...
ssh aws-kacperjakub2099 "gunzip -f affine-backend-prod.tar.gz && sudo k3s ctr images import affine-backend-prod.tar && rm affine-backend-prod.tar"

echo.
echo Step 6: Copying Kubernetes manifests to EC2...
scp -r k8s aws-kacperjakub2099:~/

echo.
echo Step 7: Applying Kubernetes manifests...
ssh aws-kacperjakub2099 "sudo k3s kubectl apply -f k8s/"

echo.
echo Step 8: Restarting AFFiNE deployment to pick up new image...
ssh aws-kacperjakub2099 "sudo k3s kubectl rollout restart deployment affine -n affine"

echo.
echo Step 9: Cleaning up local files...
del affine-backend-prod.tar
del affine-backend-prod.tar.gz

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo Check status with: ssh aws-kacperjakub2099 "sudo k3s kubectl get pods -n affine"
echo.

