---
description: How to separate dev and prod environments with Docker
---

# Docker Environment Separation - Best Practices for AFFiNE

This guide explains how to properly separate development and production environments in the AFFiNE repository using Docker, following industry best practices.

## Current State Analysis

The AFFiNE repository already has some environment separation:

1. **`.docker/dev/`** - Development services (postgres, redis, mailpit, manticoresearch)
2. **`.docker/selfhost/`** - Production self-hosted setup
3. **Root `docker-compose.yml`** - Your custom development setup with Gemini integration

## Best Practices for Environment Separation

### 1. **Use Environment-Specific Docker Compose Files**

Instead of one `docker-compose.yml`, create:
- `docker-compose.dev.yml` - Development environment
- `docker-compose.prod.yml` - Production environment
- `docker-compose.override.yml` - Local developer overrides (gitignored)

### 2. **Environment Variables Strategy**

Create separate `.env` files:
- `.env.dev` - Development configuration
- `.env.prod` - Production configuration
- `.env.local` - Local overrides (gitignored)
- `.env.example` - Template for all environments

### 3. **Multi-Stage Dockerfiles**

Use build targets for different environments:
```dockerfile
# Development stage
FROM node:22-bookworm AS development
# ... dev dependencies and tools

# Production stage
FROM node:22-bookworm AS production
# ... only production dependencies
```

## Recommended Structure for AFFiNE

### Directory Layout
```
AFFiNE/
├── .docker/
│   ├── dev/
│   │   ├── .env.example
│   │   ├── compose.yml          # Dev services only
│   │   └── README.md
│   ├── prod/
│   │   ├── .env.example
│   │   ├── compose.yml          # Prod services
│   │   └── README.md
│   └── shared/
│       └── nginx/               # Shared configs
├── docker/
│   ├── Dockerfile.dev           # Development build
│   ├── Dockerfile.prod          # Production build
│   └── gemini-bridge/
│       └── Dockerfile
├── docker-compose.dev.yml       # Full dev stack
├── docker-compose.prod.yml      # Full prod stack
├── .env.dev.example
├── .env.prod.example
└── .gitignore                   # Ignore .env.*.local files
```

## Implementation Steps

### Step 1: Create Environment-Specific Dockerfiles

**`docker/Dockerfile.dev`** - Optimized for development:
- Hot reload support
- Volume mounts for source code
- Development dependencies included
- Debug tools enabled
- Faster builds (less optimization)

**`docker/Dockerfile.prod`** - Optimized for production:
- Multi-stage build
- Minimal image size
- Only production dependencies
- Security hardening
- Optimized builds

### Step 2: Create Environment-Specific Compose Files

**`docker-compose.dev.yml`**:
```yaml
version: '3.8'

services:
  affine:
    build:
      context: .
      dockerfile: docker/Dockerfile.dev
      target: development
    env_file:
      - .env.dev
      - .env.dev.local  # Optional local overrides
    environment:
      - NODE_ENV=development
      - DEBUG=affine:*
    volumes:
      # Mount source for hot reload
      - ./packages:/app/packages:cached
      - ./blocksuite:/app/blocksuite:cached
    ports:
      - "3010:3010"
      - "9229:9229"  # Node debugger
```

**`docker-compose.prod.yml`**:
```yaml
version: '3.8'

services:
  affine:
    build:
      context: .
      dockerfile: docker/Dockerfile.prod
      target: production
    env_file:
      - .env.prod
    environment:
      - NODE_ENV=production
    # No source mounts in production
    restart: unless-stopped
```

### Step 3: Create Environment Variable Templates

**`.env.dev.example`**:
```env
# Development Environment Configuration
NODE_ENV=development
AFFINE_ENV=dev

# Server Configuration
PORT=3010
HOST=0.0.0.0
AFFINE_SERVER_EXTERNAL_URL=http://localhost:3010
AFFINE_SERVER_HTTPS=false

# Database (Development)
DB_USERNAME=affine_dev
DB_PASSWORD=dev_password_change_me
DB_DATABASE=affine_dev
DATABASE_URL=postgresql://affine_dev:dev_password_change_me@postgres:5432/affine_dev

# Redis
REDIS_SERVER_HOST=redis

# Features (Development - Enable All)
AFFINE_COPILOT_ENABLED=true
AFFINE_INDEXER_ENABLED=true
AFFINE_AUTH_ENABLED=false  # Easier dev without auth

# Gemini WebAPI (Development)
AFFINE_COPILOT_PROVIDERS_GEMINIWEBAPI_BASE_URL=http://gemini-bridge:8765
AFFINE_COPILOT_PROVIDERS_GEMINIWEBAPI_ENABLED=true

# Debug
DEBUG=affine:*
LOG_LEVEL=debug
```

**`.env.prod.example`**:
```env
# Production Environment Configuration
NODE_ENV=production
AFFINE_ENV=production

# Server Configuration
PORT=3010
HOST=0.0.0.0
AFFINE_SERVER_EXTERNAL_URL=https://your-domain.com
AFFINE_SERVER_HTTPS=true

# Database (Production - Use Secrets!)
DB_USERNAME=affine
DB_PASSWORD=  # Set via secrets management
DB_DATABASE=affine
DATABASE_URL=  # Set via secrets management

# Redis
REDIS_SERVER_HOST=redis

# Features (Production - Selective)
AFFINE_COPILOT_ENABLED=true
AFFINE_INDEXER_ENABLED=false  # Resource intensive
AFFINE_AUTH_ENABLED=true

# Gemini WebAPI (Production)
AFFINE_COPILOT_PROVIDERS_GEMINIWEBAPI_BASE_URL=http://gemini-bridge:8765
AFFINE_COPILOT_PROVIDERS_GEMINIWEBAPI_ENABLED=true

# Logging
LOG_LEVEL=info
```

### Step 4: Update .gitignore

Add to `.gitignore`:
```
# Environment files
.env.dev.local
.env.prod.local
.env.local
.env

# Docker overrides
docker-compose.override.yml
```

## Usage Commands

### Development Environment

```bash
# Start dev environment
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f affine

# Rebuild after changes
docker-compose -f docker-compose.dev.yml up -d --build

# Stop
docker-compose -f docker-compose.dev.yml down

# Stop and remove volumes (fresh start)
docker-compose -f docker-compose.dev.yml down -v
```

### Production Environment

```bash
# Start prod environment
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Update to latest
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# Stop
docker-compose -f docker-compose.prod.yml down
```

### Using Environment Files

```bash
# Specify env file explicitly
docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d

# With local overrides
docker-compose -f docker-compose.dev.yml \
  --env-file .env.dev \
  --env-file .env.dev.local \
  up -d
```

## Advanced: Docker Compose Profiles

Use profiles to selectively start services:

```yaml
services:
  gemini-bridge:
    profiles: ["ai", "full"]
    # ... config
  
  mailpit:
    profiles: ["dev", "full"]
    # ... config
```

Usage:
```bash
# Start only core services
docker-compose -f docker-compose.dev.yml up -d

# Start with AI services
docker-compose -f docker-compose.dev.yml --profile ai up -d

# Start everything
docker-compose -f docker-compose.dev.yml --profile full up -d
```

## Security Best Practices

### 1. **Never Commit Secrets**
- Use `.env.example` files as templates
- Store actual secrets in `.env.*.local` files (gitignored)
- Use Docker secrets or external secret management in production

### 2. **Different Credentials Per Environment**
- Dev: Simple passwords, local databases
- Prod: Strong passwords, managed databases, encrypted connections

### 3. **Network Isolation**
```yaml
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access
```

### 4. **Resource Limits (Production)**
```yaml
services:
  affine:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
```

## Migration from Current Setup

### Current State
You have `docker-compose.yml` at the root with your custom Gemini integration.

### Migration Steps

1. **Backup current setup**:
   ```bash
   cp docker-compose.yml docker-compose.backup.yml
   ```

2. **Create new structure**:
   - Move current `docker-compose.yml` → `docker-compose.dev.yml`
   - Move `Dockerfile.dev` → `docker/Dockerfile.dev`
   - Create `.env.dev` from current environment variables

3. **Create production version**:
   - Copy and modify for production needs
   - Remove development-specific mounts and ports

4. **Test both environments**:
   ```bash
   # Test dev
   docker-compose -f docker-compose.dev.yml config
   docker-compose -f docker-compose.dev.yml up -d
   
   # Test prod
   docker-compose -f docker-compose.prod.yml config
   docker-compose -f docker-compose.prod.yml up -d
   ```

## Comparison: Git-like Workflow vs Docker

| Aspect | Git Workflow | Docker Workflow |
|--------|-------------|-----------------|
| **Branching** | `git checkout dev/prod` | `docker-compose -f docker-compose.{dev\|prod}.yml` |
| **Environment** | Same machine, different code | Same code, different containers |
| **Isolation** | File-based | Container-based (stronger) |
| **Dependencies** | Shared on host | Isolated per container |
| **State** | Committed code | Images + volumes |
| **Switching** | Fast (seconds) | Slower (rebuild/pull) |
| **Cleanup** | `git clean` | `docker-compose down -v` |

## Recommended Workflow

### Daily Development
```bash
# Morning: Start dev environment
docker-compose -f docker-compose.dev.yml up -d

# Work with hot reload (code changes reflect immediately)
# Edit files in your IDE

# View logs
docker-compose -f docker-compose.dev.yml logs -f affine

# Evening: Stop (keep data)
docker-compose -f docker-compose.dev.yml stop
```

### Testing Production Build
```bash
# Build production image
docker-compose -f docker-compose.prod.yml build

# Test locally
docker-compose -f docker-compose.prod.yml up -d

# Verify
curl http://localhost:3010

# Stop
docker-compose -f docker-compose.prod.yml down
```

### Fresh Start
```bash
# Nuclear option: Remove everything and start fresh
docker-compose -f docker-compose.dev.yml down -v
docker system prune -a --volumes
docker-compose -f docker-compose.dev.yml up -d --build
```

## Troubleshooting

### Issue: Changes not reflecting
**Dev**: Check volume mounts are correct
**Prod**: Rebuild image (`--build` flag)

### Issue: Port conflicts
Check `.env` file for port configurations, or use different ports per environment

### Issue: Database connection errors
Verify `DATABASE_URL` matches the service name in docker-compose

### Issue: Slow builds
- Use `.dockerignore` to exclude unnecessary files
- Use multi-stage builds
- Leverage build cache
- Consider using bind mounts in dev instead of COPY

## Next Steps

1. **Create the new structure** following the steps above
2. **Test both environments** thoroughly
3. **Document environment-specific configurations** in README
4. **Set up CI/CD** to build and test both environments
5. **Consider orchestration** (Kubernetes, Docker Swarm) for production scaling

## Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [12-Factor App Methodology](https://12factor.net/)
- [Docker Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
