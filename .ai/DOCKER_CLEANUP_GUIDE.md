# Docker Cleanup Script for AFFiNE
# This removes old/unused containers while keeping only development environment

## 🗑️ Containers to Remove

### Production Containers (Old/Failed)
These are from a previous production deployment attempt and should be removed:

1. **affine_migration_prod** - Failed migration job (exit code 1, 30 hours ago)
2. **affine_migration_job** - Another migration container (6 days old)
3. Any other containers with `stable` tag or without `_dev` suffix

### What to Keep
Only these development containers:
- **affine_server_dev** - Development backend
- **affine_postgres_dev** - Development database  
- **affine_redis_dev** - Development cache

## 🧹 Cleanup Commands

### Step 1: Stop All Containers
```powershell
# Stop dev environment
docker-compose -f docker-compose.dev.yml down

# Stop prod environment (if any)
docker-compose -f docker-compose.prod.yml down

# Stop any other compose stacks
docker-compose -f docker-compose.yml down
```

### Step 2: Remove Specific Failed Containers
```powershell
# Remove failed production containers
docker rm affine_migration_prod
docker rm affine_migration_job

# Remove any other stopped containers
docker container prune -f
```

### Step 3: Clean Up Networks
```powershell
# Remove unused networks
docker network prune -f
```

### Step 4: Clean Up Volumes (⚠️ CAREFUL - This deletes data!)
```powershell
# List volumes first to see what exists
docker volume ls

# Remove only unused volumes (safe)
docker volume prune -f

# To remove specific volumes:
# docker volume rm volume_name
```

### Step 5: Remove Unused Images
```powershell
# Remove dangling images
docker image prune -f

# Remove all unused images (more aggressive)
docker image prune -a -f
```

## ✅ Recommended Cleanup (Safe)

Run these commands in order:

```powershell
# 1. Stop everything
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.prod.yml down 2>$null
docker-compose -f docker-compose.yml down 2>$null

# 2. Remove stopped containers
docker container prune -f

# 3. Remove unused networks
docker network prune -f

# 4. Remove unused images
docker image prune -f

# 5. Restart only development environment
docker-compose -f docker-compose.dev.yml up -d
```

## 🎯 After Cleanup

You should have **only 3 containers**:
1. `affine_server_dev` - Backend API
2. `affine_postgres_dev` - Database
3. `affine_redis_dev` - Cache

Plus **1 network**:
- `affine_dev_network`

Plus **named volumes** (if you want to keep data):
- `affine_dev_postgres_data`
- `affine_dev_redis_data`

## 📊 Why So Many Containers?

The extra containers came from:
1. **Multiple compose files** - You have 6 different docker-compose files
2. **Failed deployments** - Production containers that crashed
3. **No cleanup** - Old containers accumulate over time

## 🛡️ Best Practice: One Environment at a Time

**Development:**
```powershell
docker-compose -f docker-compose.dev.yml up -d
```

**Production:**
```powershell
docker-compose -f docker-compose.prod.yml up -d
```

**Never run both simultaneously** - They conflict on ports!

## 🔍 Check Current State

After cleanup, verify:
```powershell
# Should show only 3 containers
docker ps

# Should show only dev network
docker network ls | Select-String "affine"

# Should show only dev volumes
docker volume ls | Select-String "affine"
```
