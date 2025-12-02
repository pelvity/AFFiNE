# Docker Environment Separation for AFFiNE

> **TL;DR**: Separate development and production Docker environments with best practices, similar to Git branches but for infrastructure.

## 🎯 Quick Start

### For Development (Daily Work)
```bash
cp .env.dev.example .env.dev.local
docker-compose -f docker-compose.dev.yml up -d
```
Open http://localhost:3010

### For Production (Deployment)
```bash
cp .env.prod.example .env.prod.local
# Edit .env.prod.local with strong secrets!
docker-compose -f docker-compose.prod.yml up -d
```

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[DOCKER_ENV_SETUP_SUMMARY.md](./DOCKER_ENV_SETUP_SUMMARY.md)** | Complete overview and getting started guide |
| **[DOCKER_QUICK_REFERENCE.md](./DOCKER_QUICK_REFERENCE.md)** | Common commands and troubleshooting |
| **[DOCKER_ENV_COMPARISON.md](./DOCKER_ENV_COMPARISON.md)** | Visual comparison of environments |
| **[.agent/workflows/docker-env-separation.md](./.agent/workflows/docker-env-separation.md)** | Detailed best practices guide |

## 🗂️ Files Created

### Configuration Templates
- `.env.dev.example` - Development environment template
- `.env.prod.example` - Production environment template

### Docker Compose Files
- `docker-compose.dev.yml` - Development environment
- `docker-compose.prod.yml` - Production environment

### Your Local Files (Gitignored)
- `.env.dev.local` - Your development config
- `.env.prod.local` - Your production config

## 🔑 Key Concepts

### Think of it Like Git Branches
```bash
# Git                              # Docker Environments
git checkout dev              →    docker-compose -f docker-compose.dev.yml up
git checkout main             →    docker-compose -f docker-compose.prod.yml up
```

### Environment Differences

| Aspect | Development | Production |
|--------|------------|------------|
| **Purpose** | Fast iteration | Stable deployment |
| **Source Code** | Mounted (hot reload) | Baked into image |
| **Security** | Relaxed | Hardened |
| **Ports** | All exposed | Minimal |
| **Debugging** | Enabled | Disabled |
| **Logging** | Verbose | Structured |

## 🚀 Common Commands

### Development
```bash
# Start
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f affine

# Stop
docker-compose -f docker-compose.dev.yml down

# Fresh start
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up -d --build
```

### Production
```bash
# Start
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Update
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d

# Stop
docker-compose -f docker-compose.prod.yml down
```

## 🎨 What You Get

### Development Environment
✅ Hot reload - code changes reflect immediately  
✅ Debugger port exposed (:9229)  
✅ Email testing with Mailpit  
✅ All features enabled  
✅ Simple passwords  
✅ Verbose logging  

### Production Environment
✅ Security hardened  
✅ Resource limits enforced  
✅ Automatic migrations  
✅ Health checks  
✅ Minimal attack surface  
✅ Production logging  

## 🔐 Security Notes

### Development
- Uses simple passwords (e.g., `dev_password_change_me`)
- Auth disabled for convenience
- All ports exposed for testing

### Production
- **NEVER use default passwords**
- **ALWAYS set strong secrets**
- **NEVER commit `.env.prod.local`**

Generate secrets:
```bash
openssl rand -base64 32  # For JWT_SECRET
openssl rand -base64 32  # For SESSION_SECRET
```

## 🔄 Migration from Current Setup

Your current `docker-compose.yml` is still intact. To migrate:

1. **Backup current data**
   ```bash
   docker exec affine_postgres pg_dump -U affine -d affine > backup.sql
   ```

2. **Stop current environment**
   ```bash
   docker-compose down
   ```

3. **Start new dev environment**
   ```bash
   cp .env.dev.example .env.dev.local
   docker-compose -f docker-compose.dev.yml up -d
   ```

4. **Import data (optional)**
   ```bash
   docker-compose -f docker-compose.dev.yml exec -T postgres \
     psql -U affine_dev -d affine_dev < backup.sql
   ```

## 🆘 Troubleshooting

### Port Already in Use
Edit `.env.dev.local`:
```env
PORT=3011
```

### Database Connection Issues
```bash
# Check postgres health
docker-compose -f docker-compose.dev.yml exec postgres pg_isready

# View logs
docker-compose -f docker-compose.dev.yml logs postgres
```

### Changes Not Reflecting
```bash
# Rebuild
docker-compose -f docker-compose.dev.yml up -d --build affine
```

### Fresh Start
```bash
docker-compose -f docker-compose.dev.yml down -v
docker system prune -a --volumes
docker-compose -f docker-compose.dev.yml up -d --build
```

## 📊 Services Included

### Core Services (Both Environments)
- **AFFiNE Server** - Main application
- **PostgreSQL** - Database with pgvector
- **Redis** - Cache and session store
- **Gemini Bridge** - AI integration

### Development Only
- **Mailpit** - Email testing UI (optional, use `--profile full`)
- **ManticoreSearch** - Search engine (optional, use `--profile search`)

### Production Only
- **Migration Job** - Runs database migrations before startup
- **Nginx** - Reverse proxy (optional, use `--profile nginx`)

## 🎯 Profiles

Start optional services:

```bash
# Development with email testing
docker-compose -f docker-compose.dev.yml --profile full up -d

# Development with search
docker-compose -f docker-compose.dev.yml --profile search up -d

# Production with nginx
docker-compose -f docker-compose.prod.yml --profile nginx up -d
```

## 📈 Next Steps

1. ✅ Try the development environment
2. ✅ Customize `.env.dev.local` if needed
3. ✅ Test your Gemini integration
4. ⏭️ Create `Dockerfile.prod` for optimized production builds
5. ⏭️ Set up CI/CD for both environments
6. ⏭️ Configure nginx for production
7. ⏭️ Implement automated backups

## 💡 Best Practices

1. **Never commit `.env.*.local` files** - They contain secrets
2. **Use profiles to save resources** - Only run what you need
3. **Check logs regularly** - `docker-compose logs -f`
4. **Test production locally** - Before deploying
5. **Backup regularly** - Especially in production
6. **Monitor resource usage** - `docker stats`

## 🤝 Team Collaboration

### Share (Committed to Git)
- `.env.dev.example`
- `.env.prod.example`
- `docker-compose.dev.yml`
- `docker-compose.prod.yml`
- Documentation files

### Never Share (Gitignored)
- `.env.dev.local`
- `.env.prod.local`
- Any files with actual secrets

## 📞 Need Help?

1. Check **[DOCKER_QUICK_REFERENCE.md](./DOCKER_QUICK_REFERENCE.md)** for common commands
2. Review **[DOCKER_ENV_COMPARISON.md](./DOCKER_ENV_COMPARISON.md)** for visual guides
3. Read **[DOCKER_ENV_SETUP_SUMMARY.md](./DOCKER_ENV_SETUP_SUMMARY.md)** for detailed explanations
4. Check **[.agent/workflows/docker-env-separation.md](./.agent/workflows/docker-env-separation.md)** for best practices

## 🎉 Benefits

✅ Clear separation between dev and prod  
✅ Secrets never committed to git  
✅ Easy to switch between environments  
✅ Reproducible across team  
✅ Industry-standard approach  
✅ Comprehensive documentation  
✅ Scalable to more environments  

---

**Ready?** Start with:
```bash
cp .env.dev.example .env.dev.local
docker-compose -f docker-compose.dev.yml up -d
```

Then open http://localhost:3010 🚀
