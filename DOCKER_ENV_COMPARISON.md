# Environment Comparison Chart

## Architecture Overview

### Current Setup (docker-compose.yml)
```
┌─────────────────────────────────────────────────────────┐
│                  docker-compose.yml                      │
│                  (Mixed Environment)                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ AFFiNE   │  │ Gemini   │  │ Postgres │             │
│  │ Server   │  │ Bridge   │  │          │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                                          │
│  ┌──────────┐                                           │
│  │  Redis   │                                           │
│  └──────────┘                                           │
│                                                          │
│  • Mixed dev/prod config                                │
│  • Some source mounts                                   │
│  • Basic security                                       │
│  • Single environment                                   │
└─────────────────────────────────────────────────────────┘
```

### New Development Setup (docker-compose.dev.yml)
```
┌─────────────────────────────────────────────────────────┐
│              docker-compose.dev.yml                      │
│              (Pure Development)                          │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────┐              │
│  │         AFFiNE Server (Dev)          │              │
│  │  • Hot Reload ✓                      │              │
│  │  • Debugger Port :9229 ✓             │              │
│  │  • Source Mounted ✓                  │              │
│  │  • Auth Disabled ✓                   │              │
│  │  • Debug Logging ✓                   │              │
│  └──────────────────────────────────────┘              │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Gemini   │  │ Postgres │  │  Redis   │             │
│  │ Bridge   │  │  (Dev)   │  │  (Dev)   │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                                          │
│  ┌──────────┐  ┌──────────┐                            │
│  │ Mailpit  │  │Manticore │  (Optional Profiles)       │
│  │ :8025    │  │ Search   │                            │
│  └──────────┘  └──────────┘                            │
│                                                          │
│  Configuration: .env.dev.local                          │
│  • Simple passwords                                     │
│  • All features enabled                                 │
│  • Verbose logging                                      │
│  • All ports exposed                                    │
└─────────────────────────────────────────────────────────┘
```

### New Production Setup (docker-compose.prod.yml)
```
┌─────────────────────────────────────────────────────────┐
│             docker-compose.prod.yml                      │
│             (Pure Production)                            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────┐              │
│  │      AFFiNE Server (Production)      │              │
│  │  • No Source Mounts ✓                │              │
│  │  • Resource Limits ✓                 │              │
│  │  • Auth Enabled ✓                    │              │
│  │  • Minimal Logging ✓                 │              │
│  │  • Health Checks ✓                   │              │
│  │  • Auto Restart ✓                    │              │
│  └──────────────────────────────────────┘              │
│                                                          │
│  ┌──────────────────┐                                   │
│  │   Migration Job  │  (Runs before server)            │
│  └──────────────────┘                                   │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Gemini   │  │ Postgres │  │  Redis   │             │
│  │ Bridge   │  │  (Prod)  │  │  (Prod)  │             │
│  │ Internal │  │ Internal │  │ Internal │             │
│  └──────────┘  └──────────┘  └──────────┘             │
│                                                          │
│  ┌──────────┐                                           │
│  │  Nginx   │  (Optional Profile)                      │
│  │  :80/443 │                                           │
│  └──────────┘                                           │
│                                                          │
│  Configuration: .env.prod.local                         │
│  • Strong secrets (via secrets mgmt)                    │
│  • Selective features                                   │
│  • Structured logging                                   │
│  • Minimal ports exposed                                │
└─────────────────────────────────────────────────────────┘
```

## Feature Comparison Matrix

| Feature                    | Current | Dev Setup | Prod Setup |
|----------------------------|---------|-----------|------------|
| **Source Code Mounting**   | Partial | ✅ Full   | ❌ None    |
| **Hot Reload**             | ❌      | ✅        | ❌         |
| **Debugger Port**          | ❌      | ✅ :9229  | ❌         |
| **Auth Required**          | ❌      | ❌        | ✅         |
| **Resource Limits**        | ❌      | ❌        | ✅         |
| **Health Checks**          | Basic   | ✅ Full   | ✅ Full    |
| **Auto Restart**           | ✅      | ✅        | ✅         |
| **Migration Job**          | ❌      | ❌        | ✅         |
| **Email Testing (Mailpit)**| ❌      | ✅        | ❌         |
| **Search Engine**          | ❌      | ✅ Opt.   | ❌         |
| **Nginx Proxy**            | ❌      | ❌        | ✅ Opt.    |
| **Logging Level**          | Info    | Debug     | Info/Warn  |
| **Exposed Ports**          | Many    | All       | Minimal    |
| **Network Isolation**      | ❌      | ❌        | ✅         |
| **Secrets Management**     | ❌      | ❌        | ✅         |

## Port Mapping Comparison

### Development Environment
```
External → Internal
─────────────────────
3010    → 3010     (AFFiNE Server)
9229    → 9229     (Node Debugger)
8765    → 8765     (Gemini Bridge)
5432    → 5432     (PostgreSQL)
6379    → 6379     (Redis)
8025    → 8025     (Mailpit UI)
1025    → 1025     (Mailpit SMTP)
9308    → 9308     (Manticore Search)
```

### Production Environment
```
External → Internal
─────────────────────
3010    → 3010     (AFFiNE Server ONLY)
─       → 8765     (Gemini Bridge - Internal)
─       → 5432     (PostgreSQL - Internal)
─       → 6379     (Redis - Internal)

With Nginx Profile:
80      → 80       (HTTP)
443     → 443      (HTTPS)
```

## Environment Variables Flow

### Development (.env.dev.local)
```
┌─────────────────────┐
│  .env.dev.example   │  (Template - Committed to Git)
└──────────┬──────────┘
           │ copy
           ▼
┌─────────────────────┐
│  .env.dev.local     │  (Your Config - Gitignored)
└──────────┬──────────┘
           │ loaded by
           ▼
┌─────────────────────┐
│ docker-compose.dev  │
│       .yml          │
└──────────┬──────────┘
           │ creates
           ▼
┌─────────────────────┐
│   Dev Containers    │
└─────────────────────┘
```

### Production (.env.prod.local)
```
┌─────────────────────┐
│  .env.prod.example  │  (Template - Committed to Git)
└──────────┬──────────┘
           │ copy
           ▼
┌─────────────────────┐
│  .env.prod.local    │  (Your Config - Gitignored)
│                     │  + Secrets Management
└──────────┬──────────┘
           │ loaded by
           ▼
┌─────────────────────┐
│ docker-compose.prod │
│       .yml          │
└──────────┬──────────┘
           │ creates
           ▼
┌─────────────────────┐
│   Prod Containers   │
└─────────────────────┘
```

## Workflow Comparison

### Git-like Analogy
```
Git Branches              Docker Environments
─────────────────────────────────────────────
git checkout dev      →   docker-compose -f docker-compose.dev.yml up
git checkout main     →   docker-compose -f docker-compose.prod.yml up
git branch -D dev     →   docker-compose -f docker-compose.dev.yml down -v
git status            →   docker-compose -f docker-compose.dev.yml ps
git log               →   docker-compose -f docker-compose.dev.yml logs
```

### Daily Development Workflow
```
Morning                    Afternoon                  Evening
────────                   ─────────                  ───────
Start Dev Env              Make Changes               Stop/Keep Running
     │                          │                          │
     ▼                          ▼                          ▼
docker-compose -f      Edit Code in IDE      docker-compose -f
docker-compose.dev     (Hot Reload!)         docker-compose.dev
.yml up -d                                   .yml stop
     │                          │                          │
     ▼                          ▼                          ▼
Open Browser           See Changes Live       Data Persists
localhost:3010         No Rebuild Needed      for Tomorrow
```

### Production Deployment Workflow
```
Local Testing              Build                    Deploy
─────────────              ─────                    ──────
Test Locally               Build Prod Image         Deploy to Server
     │                          │                          │
     ▼                          ▼                          ▼
docker-compose -f      docker-compose -f        docker-compose -f
docker-compose.prod    docker-compose.prod      docker-compose.prod
.yml up -d             .yml build               .yml up -d
     │                          │                          │
     ▼                          ▼                          ▼
Verify Locally         Push to Registry         Monitor Logs
localhost:3010         (Optional)               & Health
```

## Security Comparison

### Development (Relaxed)
```
┌────────────────────────────────┐
│     Development Security       │
├────────────────────────────────┤
│ ✅ Simple passwords            │
│ ✅ Auth disabled               │
│ ✅ All ports exposed           │
│ ✅ Debug mode enabled          │
│ ✅ Verbose logging             │
│ ✅ No secrets management       │
│ ✅ Source code mounted         │
│                                │
│ Goal: Easy Development         │
└────────────────────────────────┘
```

### Production (Hardened)
```
┌────────────────────────────────┐
│     Production Security        │
├────────────────────────────────┤
│ ⚠️  Strong passwords (32+ char)│
│ ⚠️  Auth required              │
│ ⚠️  Minimal ports exposed      │
│ ⚠️  Debug disabled             │
│ ⚠️  Structured logging         │
│ ⚠️  Secrets management         │
│ ⚠️  No source mounts           │
│ ⚠️  Resource limits            │
│ ⚠️  Network isolation          │
│                                │
│ Goal: Maximum Security         │
└────────────────────────────────┘
```

## Resource Usage Comparison

### Development (No Limits)
```
Service          CPU    Memory    Notes
─────────────────────────────────────────
AFFiNE Server    Any    Any       No limits for development
Gemini Bridge    Any    2GB SHM   Playwright needs shared memory
PostgreSQL       Any    Any       No limits
Redis            Any    Any       No limits
Mailpit          Any    Any       Lightweight
Total            ~4GB+  ~6GB+     Approximate
```

### Production (With Limits)
```
Service          CPU       Memory      Notes
──────────────────────────────────────────────
AFFiNE Server    1-2 CPU   2-4 GB      Enforced limits
Gemini Bridge    0.5-1 CPU 1-2 GB      Enforced limits
PostgreSQL       1-2 CPU   2-4 GB      Enforced limits
Redis            0.5-1 CPU 512MB-1GB   Enforced limits
Total            3-6 CPU   5.5-11 GB   Controlled usage
```

## Data Persistence

### Development
```
Windows Paths:
C:\Users\admin\.affine\dev\
├── config\              (AFFiNE config)
├── storage\             (Uploaded files)
└── postgres\pgdata\     (Database)

Docker Volumes:
- affine_dev_mailpit_data
- affine_dev_manticore_data
```

### Production
```
Linux Paths (in containers):
/root/.affine/
├── config\              (AFFiNE config)
└── storage\             (Uploaded files)

/var/lib/postgresql/data (Database)

Docker Volumes:
- affine_prod_gemini_cookies
- affine_prod_gemini_browser
```

## Command Cheat Sheet

### Switch Environments
```bash
# Start Development
docker-compose -f docker-compose.dev.yml up -d

# Start Production
docker-compose -f docker-compose.prod.yml up -d

# Stop Development
docker-compose -f docker-compose.dev.yml down

# Stop Production
docker-compose -f docker-compose.prod.yml down
```

### View Status
```bash
# Development
docker-compose -f docker-compose.dev.yml ps
docker-compose -f docker-compose.dev.yml logs -f

# Production
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

### Rebuild
```bash
# Development (rebuild single service)
docker-compose -f docker-compose.dev.yml up -d --build affine

# Production (rebuild all)
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
```

---

**Visual Summary:**
- **Current**: Single mixed environment
- **New Dev**: Optimized for development with hot reload and debugging
- **New Prod**: Optimized for production with security and performance

Choose the right environment for the right task! 🎯
