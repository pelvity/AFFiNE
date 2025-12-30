# Docker Container Audit - AFFiNE Project
**Date:** 2025-12-02 16:39 CET

## 📊 Current Container Status

### Active Containers
**None currently running**

### Stopped Containers
Based on the audit, the following containers exist but are stopped:

1. **affine_server_dev** - Development backend (Exited 137 - killed)
2. **affine_postgres_dev** - Development PostgreSQL database (Exited 0)
3. **affine_redis_dev** - Development Redis cache (Exited 0)
4. **affine_migration_prod** - Production migration job (Exited 1 - 30 hours ago)

## 🗂️ Docker Compose Files Found

1. **docker-compose.dev.yml** ✅ - Development environment
2. **docker-compose.prod.yml** - Production environment
3. **docker-compose.yml** - Default/main compose file
4. **docker-compose.desktop.yml** - Desktop app environment
5. **docker-compose.services.yml** - Shared services
6. **docker-compose.working-version.yml** - Backup/working version

## 🔍 Environment Separation Analysis

### ✅ Good Practices Observed
- **Separate dev/prod compose files** - Clear separation between environments
- **Named containers** with `_dev` suffix for development
- **Separate networks** for isolation:
  - `affine_dev_network` (development)
  - `affine_affine_net` (production)
  - `affine_affine_desktop_net` (desktop)

### ⚠️ Issues Identified

#### 1. **Mixed Container States**
- Development containers are stopped
- Production migration container failed (exit code 1)
- No clear indication of which environment is intended to be active

#### 2. **Orphaned Resources**
- **Networks:** Multiple networks exist but containers are stopped
  - `affine_affine_desktop_net`
  - `affine_affine_net`
  - `affine_default`
  - `affine_dev_network`
- **Volumes:** Anonymous and named volumes may contain stale data
  - `affine_postgres-data`
  - Multiple unnamed volumes

#### 3. **Port Conflicts Risk**
Both dev and prod likely use same ports (3010, 5432, 6379), which could cause conflicts if both run simultaneously.

## 📋 Recommendations

### Immediate Actions

1. **Clean Up Stopped Containers**
```bash
# Remove all stopped containers
docker container prune

# Or selectively remove
docker rm affine_migration_prod
```

2. **Clean Up Unused Networks**
```bash
docker network prune
```

3. **Clean Up Unused Volumes** (⚠️ CAUTION: This deletes data)
```bash
# List volumes first
docker volume ls

# Remove unused volumes
docker volume prune
```

### Best Practices to Implement

#### 1. **Port Mapping Strategy**
Update `docker-compose.dev.yml` to use different host ports:
```yaml
# Development
ports:
  - "3011:3010"  # Backend
  - "5433:5432"  # PostgreSQL
  - "6380:6379"  # Redis
```

#### 2. **Environment-Specific Networks**
Already implemented ✅ - Keep using separate networks per environment.

#### 3. **Volume Management**
Use named volumes with environment prefixes:
```yaml
volumes:
  affine_dev_postgres_data:
  affine_dev_redis_data:
  affine_prod_postgres_data:
  affine_prod_redis_data:
```

#### 4. **Container Naming Convention**
Already good ✅ - Using `_dev` and `_prod` suffixes.

#### 5. **Health Checks**
Already implemented ✅ in `docker-compose.dev.yml`.

## 🎯 Current Setup for Tool Calling Integration

### What Should Be Running (Development)
For the Gemini tool calling integration test:

1. **Frontend** - Running locally via `yarn dev` ✅
2. **Gemini Bridge** - Running locally (port 8765) ✅
3. **Backend (affine_server_dev)** - Should run in Docker (port 3010) ❌
4. **PostgreSQL (affine_postgres_dev)** - Should run in Docker (port 5432) ❌
5. **Redis (affine_redis_dev)** - Should run in Docker (port 6379) ❌

### Start Development Environment
```bash
cd C:\Users\admin\ProjectsIT\personal\AFFiNE
docker-compose -f docker-compose.dev.yml up -d
```

### Stop Development Environment
```bash
docker-compose -f docker-compose.dev.yml down
```

### View Logs
```bash
docker-compose -f docker-compose.dev.yml logs -f affine
```

## 🧹 Cleanup Commands

### Safe Cleanup (Recommended)
```bash
# Stop all containers
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.prod.yml down

# Remove stopped containers
docker container prune -f

# Remove unused networks
docker network prune -f
```

### Full Cleanup (⚠️ Deletes all data)
```bash
# Stop and remove everything including volumes
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.prod.yml down -v

# Remove all unused resources
docker system prune -a --volumes -f
```

## 📌 Summary

**Current State:** All containers are stopped. The development environment needs to be started for testing.

**Action Required:** 
1. Start development containers: `docker-compose -f docker-compose.dev.yml up -d`
2. Verify backend health: `curl http://localhost:3010/api/healthz`
3. Test tool calling in browser at: `http://localhost:8080`

**Environment Separation:** ✅ Good - Using separate compose files and naming conventions.

**Cleanup Needed:** ⚠️ Yes - Remove failed production migration container and unused resources.
