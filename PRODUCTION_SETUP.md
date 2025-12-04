# AFFiNE Production Setup - Complete Guide

## 🎯 Current Production Architecture

### Components:

1. **Backend**: Running on AWS EC2 (Docker)
2. **Frontend**: Running locally (yarn dev) OR on EC2 (to be built)
3. **Database**: PostgreSQL (Docker on EC2)
4. **Redis**: Redis (Docker on EC2)

---

## 📋 Production Configuration

### AWS EC2 Server

- **IP**: `13.48.24.34`
- **Instance ID**: `i-03fddb596325bd59c`
- **Region**: `eu-north-1`
- **Backend Port**: `3010`
- **SSH**: `ssh aws-kacperjakub2099`

### Docker Compose Files

- **Main**: `docker-compose.prod.yml`
- **Override**: `docker-compose.prod.ec2.override.yml`
- **Image**: `pelvity/affine-backend:prod`

---

## 🚀 Deployment Process

### 1. Local Changes

```bash
# Make your changes
git add .
git commit -m "Your changes"
git push origin feat/gemini-webapi
```

### 2. Deploy to AWS

```bash
# SSH to server
ssh aws-kacperjakub2099

# Navigate to project
cd AFFiNE-new

# Pull latest code
git pull origin feat/gemini-webapi

# Rebuild Docker image
docker build -t pelvity/affine-backend:prod -f Dockerfile.dev .

# Recreate containers
docker compose -f docker-compose.prod.yml -f docker-compose.prod.ec2.override.yml up -d --force-recreate affine

# Run migrations (if needed)
docker exec affine_backend_prod yarn workspace @affine/server data-migration run

# Check status
docker compose -f docker-compose.prod.yml -f docker-compose.prod.ec2.override.yml ps
docker logs affine_backend_prod --tail 50
```

---

## 💻 Local Development

### Option 1: Full Local Stack

```bash
# Start local Docker backend + frontend
start-dev.bat

# Or manually:
docker compose -f docker-compose.dev.yml up -d
yarn dev
```

- Backend: `http://localhost:3010`
- Frontend: `http://localhost:8080`

### Option 2: Frontend → AWS Backend

```bash
# Start frontend connected to AWS
start-prod-frontend.bat

# Or manually:
set AFFINE_SERVER_EXTERNAL_URL=http://13.48.24.34:3010
yarn dev
```

- Backend: `http://13.48.24.34:3010` (AWS)
- Frontend: `http://localhost:8080` (Local)

---

## 🖥️ Desktop App

### Launch Production App

```bash
launch-desktop-prod.bat
```

- Opens Chrome in app mode
- Points to: `http://localhost:8080` (requires frontend running)

### Update for Direct AWS Access

Edit `launch-desktop-prod.bat`:

```batch
start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --app=http://13.48.24.34:3010
```

---

## ✅ Features Implemented

### Password-Required Authentication

- ✅ No email verification codes
- ✅ Immediate login after password entry
- ✅ Works for both signup and login
- ✅ Email verified flag set automatically

### Modified Files:

1. `packages/backend/server/src/core/auth/controller.ts`

   - `passwordSignIn()`: Handles signup + login
   - `sendMagicLink()`: Rejects passwordless attempts

2. `packages/frontend/core/src/components/sign-in/sign-in.tsx`

   - Always redirects to password step

3. `packages/frontend/core/src/components/sign-in/sign-in-with-password.tsx`

   - Shows "Create Account" for new users
   - Shows "Sign In" for existing users

4. `packages/frontend/core/src/modules/cloud/services/auth.ts`
   - Detects immediate login response

---

## 🔧 Environment Variables

### Production (.env.prod.local)

```bash
AFFINE_SERVER_EXTERNAL_URL=http://13.48.24.34:3010
DATABASE_URL=postgresql://affine:SecureProductionPassword123@postgres:5432/affine
REDIS_SERVER_HOST=redis
AFFINE_COPILOT_ENABLED=true
```

### Development (.env.dev)

```bash
AFFINE_SERVER_EXTERNAL_URL=http://localhost:3010
DATABASE_URL=postgresql://affine_dev:dev_password_change_me@postgres:5432/affine_dev
REDIS_SERVER_HOST=redis
```

---

## 🐛 Troubleshooting

### Backend not responding

```bash
ssh aws-kacperjakub2099
docker logs affine_backend_prod --tail 100
docker compose -f docker-compose.prod.yml -f docker-compose.prod.ec2.override.yml restart affine
```

### Database errors

```bash
# Run migrations
docker exec affine_backend_prod yarn workspace @affine/server data-migration run

# Check database
docker exec affine_postgres_prod psql -U affine -d affine -c "SELECT * FROM features;"
```

### Frontend proxy errors

```bash
# Check if AFFINE_SERVER_EXTERNAL_URL is set
echo %AFFINE_SERVER_EXTERNAL_URL%

# Restart frontend
# Kill yarn dev and restart
```

---

## 📊 Testing

### Test Backend API

```powershell
# Test signup
$body = @{email = "test@example.com"; password = "TestPass123!"} | ConvertTo-Json
Invoke-RestMethod -Uri "http://13.48.24.34:3010/api/auth/sign-in" -Method POST -Body $body -ContentType "application/json"

# Test login
Invoke-RestMethod -Uri "http://13.48.24.34:3010/api/auth/sign-in" -Method POST -Body $body -ContentType "application/json"
```

### Test Frontend

1. Open `http://localhost:8080` (if running locally)
2. Or `http://13.48.24.34:3010` (if on AWS)
3. Click "Sign in"
4. Enter email + password
5. Should login immediately

---

## 🔒 Security Notes

- Change database password in production
- Use HTTPS in production (add reverse proxy)
- Set up firewall rules on EC2
- Enable rate limiting
- Consider adding 2FA

---

## 📝 Quick Commands

```bash
# Deploy to AWS
ssh aws-kacperjakub2099 "cd AFFiNE-new && git pull && docker build -t pelvity/affine-backend:prod -f Dockerfile.dev . && docker compose -f docker-compose.prod.yml -f docker-compose.prod.ec2.override.yml up -d --force-recreate affine"

# Check logs
ssh aws-kacperjakub2099 "docker logs affine_backend_prod --tail 50"

# Restart backend
ssh aws-kacperjakub2099 "cd AFFiNE-new && docker compose -f docker-compose.prod.yml -f docker-compose.prod.ec2.override.yml restart affine"
```

---

## ✅ Current Status

- ✅ Backend: Running on AWS EC2
- ✅ Password Auth: Working
- ✅ Email Verification: Disabled
- ✅ Database: PostgreSQL on EC2
- ✅ Redis: Running on EC2
- ⚠️ Frontend: Running locally (can be deployed to EC2)

---

**Last Updated**: 2025-12-04
**Version**: Production v1.0
**Branch**: feat/gemini-webapi
