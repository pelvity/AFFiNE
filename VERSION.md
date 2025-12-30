# AFFiNE Production Versions

## Current Deployment
- **Version**: v1.0.3
- **Tag**: stable
- **Git Commit**: 1ed254f73
- **Deployed**: 2025-12-05 13:29
- **Features**:
  - Password-required authentication
  - Email verification bypass
  - Calendar proxy for CORS fix (WORKING)
  - Frontend + Backend in single Docker image

## Version History

### v1.0.3 (stable) - 2025-12-05 13:29
- Calendar proxy fix deployed and verified
- Frontend uses /api/calendar/proxy endpoint
- No more CORS errors on calendar subscription
- Committed from running container with manual patches

### v1.0.2 - 2025-12-05 12:30
- Attempted deployment (incomplete - no calendar fix in image)
- Superseded by v1.0.3

### v1.0.0 - 2025-12-05 01:00
- Initial production deployment
- Custom password authentication
- Calendar integration with proxy (backend only)
- Running on AWS EC2 (13.48.24.34:3010)

## Rollback Instructions

### To rollback to a specific version:
```bash
# On EC2
cd AFFiNE-new

# Option 1: Use specific version tag
docker-compose.prod.yml: change image to pelvity/affine-backend:v1.0.0

# Option 2: Retag stable to previous version
docker tag pelvity/affine-backend:v1.0.0 pelvity/affine-backend:stable

# Restart containers
docker compose -f docker-compose.prod.yml -f docker-compose.prod.ec2.override.yml up -d --force-recreate affine
```

## Creating New Versions

### Build and tag new version:
```bash
# Get git commit hash
git rev-parse --short HEAD  # e.g., 1ed254f

# Build with version tag
docker build -t pelvity/affine-backend:v1.0.1 -f Dockerfile.dev.nobuild .

# Also tag as latest
docker tag pelvity/affine-backend:v1.0.1 pelvity/affine-backend:latest

# Test it first
docker-compose.prod.yml: change image to pelvity/affine-backend:v1.0.1
docker compose up -d

# If works, promote to stable
docker tag pelvity/affine-backend:v1.0.1 pelvity/affine-backend:stable
```

## Available Tags
- `:stable` - Current production version (v1.0.0)
- `:latest` - Latest build (may be unstable)
- `:v1.0.0` - Specific version (immutable)
- `:prod` - Legacy tag (deprecated, use :stable instead)
