@echo off
echo ========================================
echo Building AFFiNE Docker Image Locally
echo ========================================
echo.

echo Step 1: Building Docker image (this will take 15-20 minutes)...
docker build -t pelvity/affine-backend:prod -f Dockerfile.prod .

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Docker build failed!
    pause
    exit /b 1
)

echo.
echo Step 2: Saving image to tar file...
docker save pelvity/affine-backend:prod -o affine-backend-prod.tar

echo.
echo Step 3: Compressing...
tar -czf affine-backend-prod.tar.gz affine-backend-prod.tar

echo.
echo Step 4: Copying to EC2 (this may take a few minutes)...
scp affine-backend-prod.tar.gz aws-kacperjakub2099:~/

echo.
echo Step 5: Loading image on EC2...
ssh aws-kacperjakub2099 "gunzip -c affine-backend-prod.tar.gz | docker load && rm affine-backend-prod.tar.gz"

echo.
echo Step 6: Restarting containers on EC2...
ssh aws-kacperjakub2099 "cd AFFiNE-new && docker compose -f docker-compose.prod.yml -f docker-compose.prod.ec2.override.yml up -d --force-recreate affine"

echo.
echo Step 7: Cleaning up local files...
del affine-backend-prod.tar
del affine-backend-prod.tar.gz

echo.
echo ========================================
echo Deployment Complete!
echo ========================================
echo Frontend is now running on EC2 at:
echo http://13.48.24.34:3010
echo.
pause
