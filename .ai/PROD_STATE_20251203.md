# Production State Snapshot - 2025-12-03

## Git Commit
- **Commit**: `3fac51d93`
- **Tag**: `prod-20251203`
- **Branch**: `feat/gemini-webapi`
- **Message**: fix: enforce naming conventions and remove workarounds for prod

## Docker Images
- `pelvity/affine-backend:prod-20251203` (18.5GB)
- `pelvity/gemini-bridge:prod-20251203` (2.32GB)

## Running Containers
All containers follow NAMING_CONVENTIONS.md:

| Container Name | Status | Ports | Image |
|----------------|--------|-------|-------|
| affine_backend_prod | Running (healthy) | 3010:3010 | pelvity/affine-backend:prod |
| affine_postgres_prod | Running (healthy) | 5432 (internal) | pgvector/pgvector:pg16 |
| affine_redis_prod | Running (healthy) | 6379 (internal) | redis:latest |
| affine_gemini_prod | Running | 8765 (internal) | gemini-bridge-prod:latest |

## Network
- **Name**: `affine_prod_network`
- **Driver**: bridge
- **Internal**: false

## Volumes
- `affine_prod_gemini_browser` - Gemini browser profile data
- Bind mounts:
  - `C:\Users\admin\.affine\prod\config` → `/root/.affine/config`
  - `C:\Users\admin\.affine\prod\storage` → `/root/.affine/storage`
  - `C:\Users\admin\.affine\prod\postgres\pgdata` → `/var/lib/postgresql/data`
  - `.gemini_cookies.json` → `/app/.gemini_cookies.json` (gemini-bridge)

## Configuration Files
- `.env.prod` - Production environment defaults (checked in)
- `.env.prod.local` - Local production secrets (gitignored)
- `docker-compose.prod.yml` - Production compose base
- `docker-compose.prod.local.override.yml` - Windows-specific overrides
- `affine-config.json` - AFFiNE copilot configuration
- `C:\Users\admin\.affine\prod\config\affine.config.json` - Runtime config

## Changes Made
1. ✅ Fixed container naming: `affine_backend_local` → `affine_backend_prod`
2. ✅ Removed Alpine workaround for gemini-bridge
3. ✅ Deleted dummy workaround files
4. ✅ Fixed Dockerfile.dev to create `/admin/` static directory
5. ✅ Changed gemini-bridge to use bind mount for cookies
6. ✅ Added NAMING_CONVENTIONS.md as single source of truth
7. ✅ Removed unused `gemini_cookies` volume

## Known Issues
- ⚠️ GeminiWebAPI provider is being unregistered despite:
  - Config file correctly placed
  - Gemini bridge healthy and reachable (`http://gemini-bridge:8765`)
  - Valid cookies loaded
  - This appears to be an AFFiNE provider validation issue requiring further investigation

## Health Status
- **Backend**: Starting (health check in progress)
- **Postgres**: Healthy
- **Redis**: Healthy
- **Gemini Bridge**: Running, cookies valid, client initialized

## How to Restore This State

### 1. Checkout Git Tag
```bash
git checkout prod-20251203
```

### 2. Pull Docker Images
```bash
docker pull pelvity/affine-backend:prod-20251203
docker pull pelvity/gemini-bridge:prod-20251203
docker tag pelvity/affine-backend:prod-20251203 pelvity/affine-backend:prod
docker tag pelvity/gemini-bridge:prod-20251203 gemini-bridge-prod:latest
```

### 3. Start Production Environment
```bash
docker-compose -f docker-compose.prod.yml -f docker-compose.prod.local.override.yml up -d
```

### 4. Copy Config (if needed)
```bash
docker cp affine-config.json affine_backend_prod:/root/.affine/config/affine.config.json
docker restart affine_backend_prod
```

## Next Steps
- [ ] Investigate GeminiWebAPI provider unregistration issue
- [ ] Test AI chat functionality in browser
- [ ] Consider creating Dockerfile.prod with multi-stage build
- [ ] Set up automated backups for postgres data
- [ ] Document provider configuration requirements
