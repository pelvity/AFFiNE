# 🚀 AFFiNE Docker Stack - Quick Reference

## 📋 Stack Overview

### Development Stack
**Purpose:** Local development with hot reload and debugging  
**Command:** `docker-compose up -d`  
**Containers:**
- `affine_server_dev` - Backend (port 3010, debugger 9229)
- `affine_postgres_dev` - Database (port 5432)
- `affine_redis_dev` - Cache (port 6379)
- Gemini Bridge - **Run locally** (not in Docker)

**Frontend:** Run separately with `yarn dev`

### Production Stack
**Purpose:** Production deployment with security and resource limits  
**Command:** `docker-compose -f docker-compose.prod.yml up -d`  
**Containers:**
- `affine_server_prod` - Backend (port 3010 only)
- `affine_postgres_prod` - Database (internal only)
- `affine_redis_prod` - Cache (internal only)
- `gemini_bridge_prod` - AI Bridge (internal only)
- `affine_migration_prod` - One-time migration job

## 🎯 Common Commands

### Development
```powershell
# Start dev environment
docker-compose up -d

# View logs
docker-compose logs -f affine

# Stop
docker-compose down

# Rebuild
docker-compose up -d --build
```

### Production
```powershell
# Start prod environment
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Stop
docker-compose -f docker-compose.prod.yml down

# Rebuild
docker-compose -f docker-compose.prod.yml up -d --build
```

## 🔄 Switching Environments

### From Dev to Prod
```powershell
# 1. Stop dev
docker-compose down

# 2. Start prod
docker-compose -f docker-compose.prod.yml up -d
```

### From Prod to Dev
```powershell
# 1. Stop prod
docker-compose -f docker-compose.prod.yml down

# 2. Start dev
docker-compose up -d
```

## 🌐 Frontend Access

### Web (Both Environments)
```powershell
# Start frontend
yarn dev

# Select: @affine/web
# Access: http://localhost:8080
```

### Desktop
```powershell
# Start desktop app
yarn dev

# Select: @affine/electron
```

**Both connect to the same backend (port 3010)**

## 🔍 Health Checks

```powershell
# Backend
curl http://localhost:3010/api/healthz

# Gemini Bridge (if running locally)
curl http://127.0.0.1:8765/health

# Database
docker exec affine_postgres_dev psql -U affine_dev -d affine_dev -c "SELECT 1"

# Redis
docker exec affine_redis_dev redis-cli ping
```

## 📊 Current Status

### Check Running Containers
```powershell
docker ps
```

### Check Networks
```powershell
docker network ls | Select-String "affine"
```

### Check Volumes
```powershell
docker volume ls | Select-String "affine"
```

## 🛑 Emergency Stop

```powershell
# Stop everything
docker stop $(docker ps -q)

# Or specific environment
docker-compose down
docker-compose -f docker-compose.prod.yml down
```

## 📁 File Structure

```
AFFiNE/
├── docker-compose.base.yml      # Shared config
├── docker-compose.override.yml  # Dev overrides (auto-loaded)
├── docker-compose.prod.yml      # Prod config
├── .env.example                 # Dev env template
├── .env.prod.example            # Prod env template
├── .env                         # Dev env (create from example)
└── .env.prod                    # Prod env (create from example)
```

## ⚙️ Environment Variables

### Development (.env)
- `ENV=dev`
- `DB_PASSWORD=dev_password_change_me`
- `GEMINI_BRIDGE_URL=http://host.docker.internal:8765` (local bridge)

### Production (.env.prod)
- `ENV=prod`
- `DB_PASSWORD=CHANGE_ME_SECURE_PASSWORD_123`
- `GEMINI_BRIDGE_URL=http://gemini-bridge:8765` (Docker bridge)

## 🎯 Testing Tool Calling

1. **Start backend:** `docker-compose up -d` (dev) or `docker-compose -f docker-compose.prod.yml up -d` (prod)
2. **Start frontend:** `yarn dev` → Select `@affine/web`
3. **Start Gemini bridge:** `py -3.12 gemini-webapi-bridge-with-tools.py` (dev only)
4. **Open browser:** `http://localhost:8080`
5. **Test chat:** Type "List all my documents"

## 📝 Notes

- **Dev:** Exposes all ports for debugging
- **Prod:** Only exposes backend port 3010
- **Gemini Bridge:** Run locally in dev, Docker in prod
- **Frontend:** Always run locally (not in Docker)
- **One environment at a time:** Don't run dev and prod simultaneously!
