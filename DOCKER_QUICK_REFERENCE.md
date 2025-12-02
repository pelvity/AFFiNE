# Docker Environment Separation - Quick Reference

## 🚀 Quick Start

### Development Environment
```bash
# 1. Copy environment template
cp .env.dev.example .env.dev.local

# 2. Edit .env.dev.local with your settings
# (Optional - defaults work for most cases)

# 3. Start development environment
docker-compose -f docker-compose.dev.yml up -d

# 4. View logs
docker-compose -f docker-compose.dev.yml logs -f affine

# 5. Access AFFiNE
# Open http://localhost:3010
```

### Production Environment
```bash
# 1. Copy environment template
cp .env.prod.example .env.prod.local

# 2. Edit .env.prod.local with production settings
# IMPORTANT: Set strong passwords and secrets!

# 3. Start production environment
docker-compose -f docker-compose.prod.yml up -d

# 4. View logs
docker-compose -f docker-compose.prod.yml logs -f

# 5. Access AFFiNE
# Open your configured domain
```

## 📋 Common Commands

### Development

```bash
# Start all services
docker-compose -f docker-compose.dev.yml up -d

# Start with specific profiles
docker-compose -f docker-compose.dev.yml --profile full up -d  # Include mailpit
docker-compose -f docker-compose.dev.yml --profile search up -d  # Include search

# Rebuild after code changes
docker-compose -f docker-compose.dev.yml up -d --build affine

# View logs (all services)
docker-compose -f docker-compose.dev.yml logs -f

# View logs (specific service)
docker-compose -f docker-compose.dev.yml logs -f affine

# Stop services (keep data)
docker-compose -f docker-compose.dev.yml stop

# Stop and remove containers (keep volumes)
docker-compose -f docker-compose.dev.yml down

# Nuclear option: Remove everything including data
docker-compose -f docker-compose.dev.yml down -v

# Execute command in container
docker-compose -f docker-compose.dev.yml exec affine sh

# View database
docker-compose -f docker-compose.dev.yml exec postgres psql -U affine_dev -d affine_dev
```

### Production

```bash
# Start all services
docker-compose -f docker-compose.prod.yml up -d

# Update to latest images
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Restart specific service
docker-compose -f docker-compose.prod.yml restart affine

# Stop services
docker-compose -f docker-compose.prod.yml down

# Backup database
docker-compose -f docker-compose.prod.yml exec postgres pg_dump -U affine -d affine > backup.sql

# Restore database
docker-compose -f docker-compose.prod.yml exec -T postgres psql -U affine -d affine < backup.sql
```

## 🔧 Troubleshooting

### Port Already in Use
```bash
# Find what's using the port
netstat -ano | findstr :3010

# Change port in .env.dev.local or .env.prod.local
PORT=3011
```

### Database Connection Issues
```bash
# Check if postgres is healthy
docker-compose -f docker-compose.dev.yml ps

# View postgres logs
docker-compose -f docker-compose.dev.yml logs postgres

# Restart postgres
docker-compose -f docker-compose.dev.yml restart postgres
```

### Changes Not Reflecting (Dev)
```bash
# Check volume mounts
docker-compose -f docker-compose.dev.yml config

# Restart with rebuild
docker-compose -f docker-compose.dev.yml up -d --build
```

### Fresh Start
```bash
# Stop everything
docker-compose -f docker-compose.dev.yml down -v

# Clean Docker system
docker system prune -a --volumes

# Start fresh
docker-compose -f docker-compose.dev.yml up -d --build
```

### View Container Details
```bash
# List running containers
docker-compose -f docker-compose.dev.yml ps

# Inspect container
docker inspect affine_server_dev

# View resource usage
docker stats
```

## 🔍 Health Checks

### Check Service Health
```bash
# All services
docker-compose -f docker-compose.dev.yml ps

# Specific service health endpoint
curl http://localhost:3010/api/healthz
```

### Database Health
```bash
# Check postgres
docker-compose -f docker-compose.dev.yml exec postgres pg_isready -U affine_dev

# Check redis
docker-compose -f docker-compose.dev.yml exec redis redis-cli ping
```

## 📊 Monitoring

### View Logs
```bash
# Follow logs (all services)
docker-compose -f docker-compose.dev.yml logs -f

# Last 100 lines
docker-compose -f docker-compose.dev.yml logs --tail=100

# Logs since timestamp
docker-compose -f docker-compose.dev.yml logs --since 2024-01-01T00:00:00
```

### Resource Usage
```bash
# Real-time stats
docker stats

# Disk usage
docker system df
```

## 🔐 Security (Production)

### Generate Secrets
```bash
# Generate JWT secret
openssl rand -base64 32

# Generate session secret
openssl rand -base64 32

# Add to .env.prod.local
JWT_SECRET=<generated-secret>
SESSION_SECRET=<generated-secret>
```

### SSL/TLS Setup
```bash
# Using Let's Encrypt with Certbot
docker run -it --rm \
  -v /etc/letsencrypt:/etc/letsencrypt \
  certbot/certbot certonly --standalone \
  -d your-domain.com
```

## 🔄 Migration from Current Setup

### Backup Current Data
```bash
# Backup current docker-compose.yml
cp docker-compose.yml docker-compose.backup.yml

# Export current database
docker exec affine_postgres pg_dump -U affine -d affine > current_db_backup.sql
```

### Switch to New Setup
```bash
# Stop current setup
docker-compose down

# Start new dev setup
docker-compose -f docker-compose.dev.yml up -d

# Import database if needed
docker-compose -f docker-compose.dev.yml exec -T postgres psql -U affine_dev -d affine_dev < current_db_backup.sql
```

## 📁 File Structure

```
AFFiNE/
├── .env.dev.example          # Development environment template
├── .env.dev.local            # Your dev settings (gitignored)
├── .env.prod.example         # Production environment template
├── .env.prod.local           # Your prod settings (gitignored)
├── docker-compose.dev.yml    # Development compose file
├── docker-compose.prod.yml   # Production compose file
├── docker-compose.yml        # Your current setup (backup)
└── Dockerfile.dev            # Development Dockerfile
```

## 🎯 Profiles

### Available Profiles

**Development:**
- `full` - Includes mailpit for email testing
- `search` - Includes manticoresearch

**Production:**
- `nginx` - Includes nginx reverse proxy

### Using Profiles
```bash
# Start with profile
docker-compose -f docker-compose.dev.yml --profile full up -d

# Multiple profiles
docker-compose -f docker-compose.dev.yml --profile full --profile search up -d
```

## 🔗 Useful URLs

**Development:**
- AFFiNE: http://localhost:3010
- Mailpit UI: http://localhost:8025
- Gemini Bridge: http://localhost:8765

**Production:**
- AFFiNE: https://your-domain.com
- (Other services not exposed externally)

## 💡 Tips

1. **Always use `.local` files for secrets** - Never commit them to git
2. **Use profiles to save resources** - Only start services you need
3. **Check logs regularly** - `docker-compose logs -f`
4. **Monitor resource usage** - `docker stats`
5. **Backup production data regularly** - Use `pg_dump` for database
6. **Test production build locally** - Before deploying
7. **Use health checks** - Ensure services are ready before depending services start

## 📚 Additional Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [AFFiNE Documentation](https://docs.affine.pro/)
- [PostgreSQL Docker](https://hub.docker.com/_/postgres)
- [Redis Docker](https://hub.docker.com/_/redis)
