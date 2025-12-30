#!/bin/bash
# Deployment script for AFFiNE password-required authentication

echo "=== Deploying AFFiNE to AWS Server ==="
echo ""

# Pull latest changes
echo "1. Pulling latest code..."
cd ~/AFFiNE
git pull origin feat/gemini-webapi

# Stop current containers
echo ""
echo "2. Stopping current containers..."
docker compose -f docker-compose.prod.yml down

# Build with latest code
echo ""
echo "3. Building Docker images..."
docker compose -f docker-compose.prod.yml build --no-cache

# Start containers
echo ""
echo "4. Starting containers..."
docker compose -f docker-compose.prod.yml up -d

# Wait for services to be healthy
echo ""
echo "5. Waiting for services to be healthy..."
sleep 30

# Check status
echo ""
echo "6. Checking container status..."
docker compose -f docker-compose.prod.yml ps

# Run data migrations
echo ""
echo "7. Running data migrations..."
docker exec affine_backend_prod yarn workspace @affine/server data-migration run

echo ""
echo "=== Deployment Complete ==="
echo "AFFiNE is now running with password-required authentication"
echo "Users can sign up/login with email + password (no email verification)"
