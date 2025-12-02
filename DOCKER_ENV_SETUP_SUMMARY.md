# Docker Environment Separation - Implementation Summary

## 📋 What Was Created

I've set up a complete Docker environment separation system for the AFFiNE repository following industry best practices. Here's what's now available:

### 1. **Documentation**
- **`.agent/workflows/docker-env-separation.md`** - Comprehensive guide on environment separation best practices
- **`DOCKER_QUICK_REFERENCE.md`** - Quick reference for common commands and troubleshooting

### 2. **Environment Configuration Templates**
- **`.env.dev.example`** - Development environment template with all configuration options
- **`.env.prod.example`** - Production environment template with security-focused settings

### 3. **Docker Compose Files**
- **`docker-compose.dev.yml`** - Development environment with hot reload and debugging
- **`docker-compose.prod.yml`** - Production environment with security hardening

### 4. **Updated Files**
- **`.gitignore`** - Updated to ignore sensitive environment files

## 🎯 Key Features

### Development Environment (`docker-compose.dev.yml`)
✅ **Hot Reload** - Source code mounted for instant changes  
✅ **Debugging** - Node.js debugger port exposed (9229)  
✅ **Development Tools** - Mailpit for email testing  
✅ **Relaxed Security** - Auth disabled for easier development  
✅ **Verbose Logging** - Debug mode enabled  
✅ **Profiles** - Optional services (mailpit, search)  
✅ **Health Checks** - Automatic service health monitoring  

### Production Environment (`docker-compose.prod.yml`)
✅ **Security Hardening** - No source mounts, minimal exposed ports  
✅ **Resource Limits** - CPU and memory constraints  
✅ **Restart Policies** - Automatic recovery from failures  
✅ **Migration Job** - Database migrations before startup  
✅ **Production Logging** - Structured logs with rotation  
✅ **Secrets Management** - Environment-based configuration  
✅ **Network Isolation** - Internal network for services  

## 🚀 Getting Started

### Option 1: Development Environment (Recommended for Daily Work)

```bash
# 1. Create your local environment file
cp .env.dev.example .env.dev.local

# 2. (Optional) Edit .env.dev.local if you need custom settings
# The defaults work for most cases

# 3. Start the development environment
docker-compose -f docker-compose.dev.yml up -d

# 4. View logs
docker-compose -f docker-compose.dev.yml logs -f affine

# 5. Access AFFiNE at http://localhost:3010
```

### Option 2: Production Environment (For Testing Production Build)

```bash
# 1. Create your production environment file
cp .env.prod.example .env.prod.local

# 2. Edit .env.prod.local and set:
#    - Strong DB_PASSWORD
#    - JWT_SECRET (generate with: openssl rand -base64 32)
#    - SESSION_SECRET (generate with: openssl rand -base64 32)
#    - AFFINE_SERVER_EXTERNAL_URL (your domain)

# 3. Start the production environment
docker-compose -f docker-compose.prod.yml up -d

# 4. View logs
docker-compose -f docker-compose.prod.yml logs -f
```

## 🔄 Migration from Your Current Setup

Your current `docker-compose.yml` is still intact. Here's how to migrate:

### Step 1: Backup Current Setup
```bash
# Backup your current compose file
cp docker-compose.yml docker-compose.backup.yml

# Export current database (if you want to keep data)
docker exec affine_postgres pg_dump -U affine -d affine > backup.sql
```

### Step 2: Stop Current Environment
```bash
# Stop current containers (keeps data)
docker-compose down
```

### Step 3: Start New Development Environment
```bash
# Create local env file
cp .env.dev.example .env.dev.local

# Start new dev environment
docker-compose -f docker-compose.dev.yml up -d

# (Optional) Import old database
docker-compose -f docker-compose.dev.yml exec -T postgres psql -U affine_dev -d affine_dev < backup.sql
```

## 📊 Comparison: Your Current Setup vs New Setup

| Aspect | Current Setup | New Dev Setup | New Prod Setup |
|--------|--------------|---------------|----------------|
| **File** | `docker-compose.yml` | `docker-compose.dev.yml` | `docker-compose.prod.yml` |
| **Environment** | Mixed dev/prod | Pure development | Pure production |
| **Source Mounts** | Some | Full (hot reload) | None |
| **Ports Exposed** | All | All + debugger | Minimal |
| **Security** | Basic | Relaxed | Hardened |
| **Resource Limits** | None | None | Enforced |
| **Health Checks** | Basic | Comprehensive | Comprehensive |
| **Logging** | Basic | Verbose | Structured |
| **Profiles** | No | Yes (mailpit, search) | Yes (nginx) |

## 🎨 Environment Separation Philosophy

### Git-like Workflow
Think of it like Git branches, but for environments:

```bash
# "Switch" to development
docker-compose -f docker-compose.dev.yml up -d

# "Switch" to production
docker-compose -f docker-compose.prod.yml up -d
```

### Key Differences

**Development:**
- Fast iteration (hot reload)
- Easy debugging
- All features enabled
- Simple passwords
- Verbose logging
- Extra tools (mailpit)

**Production:**
- Security first
- Performance optimized
- Selective features
- Strong secrets
- Minimal logging
- No debug tools

## 🔐 Security Best Practices

### Development
- ✅ Simple passwords (e.g., `dev_password_change_me`)
- ✅ Auth disabled for convenience
- ✅ All ports exposed for testing
- ✅ Debug mode enabled

### Production
- ⚠️ **NEVER use default passwords**
- ⚠️ **ALWAYS enable authentication**
- ⚠️ **NEVER expose unnecessary ports**
- ⚠️ **NEVER commit `.env.prod.local`**

### Generating Secrets
```bash
# Generate strong secrets for production
openssl rand -base64 32  # For JWT_SECRET
openssl rand -base64 32  # For SESSION_SECRET
openssl rand -base64 32  # For DB_PASSWORD
```

## 📁 File Structure

```
AFFiNE/
├── .agent/
│   └── workflows/
│       └── docker-env-separation.md    # Detailed guide
├── .env.dev.example                     # Dev template (committed)
├── .env.dev.local                       # Your dev config (gitignored)
├── .env.prod.example                    # Prod template (committed)
├── .env.prod.local                      # Your prod config (gitignored)
├── docker-compose.dev.yml               # Dev compose (committed)
├── docker-compose.prod.yml              # Prod compose (committed)
├── docker-compose.yml                   # Your current setup (backup)
├── Dockerfile.dev                       # Dev Dockerfile
├── DOCKER_QUICK_REFERENCE.md            # Quick commands
└── .gitignore                           # Updated to ignore .env.*.local
```

## 🛠️ Common Workflows

### Daily Development
```bash
# Morning: Start dev environment
docker-compose -f docker-compose.dev.yml up -d

# Work on code (changes reflect immediately via hot reload)

# View logs if needed
docker-compose -f docker-compose.dev.yml logs -f affine

# Evening: Stop (keeps data)
docker-compose -f docker-compose.dev.yml stop
```

### Testing Production Build
```bash
# Build production image
docker-compose -f docker-compose.prod.yml build

# Test locally
docker-compose -f docker-compose.prod.yml up -d

# Verify
curl http://localhost:3010/api/healthz

# Stop
docker-compose -f docker-compose.prod.yml down
```

### Fresh Start (Clean Slate)
```bash
# Stop and remove everything
docker-compose -f docker-compose.dev.yml down -v

# Clean Docker system
docker system prune -a --volumes

# Start fresh
docker-compose -f docker-compose.dev.yml up -d --build
```

## 🔍 Profiles (Optional Services)

### Development Profiles
```bash
# Start with mailpit (email testing)
docker-compose -f docker-compose.dev.yml --profile full up -d

# Start with search
docker-compose -f docker-compose.dev.yml --profile search up -d

# Start with everything
docker-compose -f docker-compose.dev.yml --profile full --profile search up -d
```

### Production Profiles
```bash
# Start with nginx reverse proxy
docker-compose -f docker-compose.prod.yml --profile nginx up -d
```

## 📈 Next Steps

### Immediate Actions
1. ✅ Review the created files
2. ✅ Try the development environment
3. ✅ Customize `.env.dev.local` if needed
4. ✅ Test your Gemini integration

### Future Enhancements
1. Create `Dockerfile.prod` (optimized multi-stage build)
2. Set up CI/CD to test both environments
3. Add nginx configuration for production
4. Implement automated backups
5. Set up monitoring (Prometheus, Grafana)
6. Consider Kubernetes for production scaling

## 🆘 Troubleshooting

### Port Conflicts
```bash
# If port 3010 is in use, change in .env.dev.local:
PORT=3011
```

### Database Issues
```bash
# Check postgres health
docker-compose -f docker-compose.dev.yml exec postgres pg_isready

# View postgres logs
docker-compose -f docker-compose.dev.yml logs postgres
```

### Changes Not Reflecting
```bash
# Rebuild the image
docker-compose -f docker-compose.dev.yml up -d --build affine
```

### View All Services
```bash
# Check status
docker-compose -f docker-compose.dev.yml ps

# View resource usage
docker stats
```

## 📚 Documentation

- **Detailed Guide**: `.agent/workflows/docker-env-separation.md`
- **Quick Reference**: `DOCKER_QUICK_REFERENCE.md`
- **Dev Config**: `.env.dev.example`
- **Prod Config**: `.env.prod.example`

## 💡 Key Takeaways

1. **Separation is Good** - Dev and prod have different needs
2. **Use `.local` Files** - Keep secrets out of git
3. **Profiles Save Resources** - Only run what you need
4. **Health Checks Matter** - Ensure services are ready
5. **Test Prod Locally** - Catch issues before deployment
6. **Document Everything** - Future you will thank you

## 🎉 Benefits

✅ **Clear Separation** - No more mixed dev/prod configs  
✅ **Security** - Secrets never committed to git  
✅ **Flexibility** - Easy to switch between environments  
✅ **Reproducibility** - Same setup across team  
✅ **Best Practices** - Industry-standard approach  
✅ **Documentation** - Comprehensive guides included  
✅ **Scalability** - Easy to add more environments (staging, etc.)  

## 🤝 Contributing

When working with team members:
1. Share `.env.*.example` files (committed)
2. Never share `.env.*.local` files (gitignored)
3. Document any new environment variables
4. Update both dev and prod configs

## 📞 Support

If you encounter issues:
1. Check `DOCKER_QUICK_REFERENCE.md` for common solutions
2. Review `.agent/workflows/docker-env-separation.md` for detailed explanations
3. Check Docker logs: `docker-compose -f docker-compose.dev.yml logs`
4. Verify environment variables: `docker-compose -f docker-compose.dev.yml config`

---

**Ready to get started?** Run:
```bash
cp .env.dev.example .env.dev.local
docker-compose -f docker-compose.dev.yml up -d
```

Then open http://localhost:3010 and enjoy your properly separated development environment! 🚀
