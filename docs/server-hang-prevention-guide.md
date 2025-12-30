# Server Hang Prevention & CPU Resource Management Guide

## Table of Contents
1. [Overview](#overview)
2. [Common Causes of Server Hangs](#common-causes-of-server-hangs)
3. [CPU Resource Reservation Strategies](#cpu-resource-reservation-strategies)
4. [Docker-Specific Resource Limits](#docker-specific-resource-limits)
5. [Monitoring & Detection](#monitoring--detection)
6. [OOM Killer Prevention](#oom-killer-prevention)
7. [Practical Implementation Examples](#practical-implementation-examples)

---

## Overview

**Can you allocate 1% of CPU for other commands?** 

**Yes!** You can reserve CPU resources for system processes and diagnostics using several Linux mechanisms:
- **cgroups (Control Groups)** - Hard CPU limits and reservations
- **systemd resource controls** - Service-level CPU quotas
- **CPU pinning (isolcpus)** - Dedicated CPU cores for critical processes
- **Process priorities (nice/renice)** - Relative CPU scheduling
- **Docker CPU limits** - Container-level resource constraints

The goal is to ensure that even when a server is under heavy load, you can still:
- SSH into the system
- Run diagnostic commands (top, htop, ps)
- Investigate what's causing the load
- Take corrective action

---

## Common Causes of Server Hangs

### 1. **CPU Exhaustion**
- Runaway processes consuming 100% CPU
- Infinite loops or inefficient algorithms
- CPU-intensive tasks without limits

### 2. **Memory Exhaustion**
- Memory leaks
- OOM (Out Of Memory) killer terminating critical processes
- Swap thrashing

### 3. **I/O Bottlenecks**
- Disk I/O saturation
- Network I/O blocking
- Database locks

### 4. **Resource Contention**
- Multiple containers/processes competing for resources
- "Noisy neighbor" problem in shared environments

---

## CPU Resource Reservation Strategies

### Strategy 1: Using cgroups (Control Groups)

**Best for:** Production environments requiring strict resource control

#### Install cgroup utilities:
```bash
# Ubuntu/Debian
sudo apt install cgroup-tools

# CentOS/RHEL
sudo yum install libcgroup
```

#### Create a cgroup with CPU limits:
```bash
# Create a cgroup named 'limited' with CPU and memory controllers
sudo cgcreate -g cpu,memory:/limited

# Set CPU quota: 50% of one CPU
# cpu.cfs_period_us = 100000 (100ms)
# cpu.cfs_quota_us = 50000 (50ms out of 100ms = 50%)
echo 50000 | sudo tee /sys/fs/cgroup/cpu/limited/cpu.cfs_quota_us
echo 100000 | sudo tee /sys/fs/cgroup/cpu/limited/cpu.cfs_period_us

# Run a process in this cgroup
sudo cgexec -g cpu:limited my_cpu_intensive_command
```

#### CPU Shares (Relative Priority):
```bash
# Default is 1024
# Set to 512 for half the priority
echo 512 | sudo tee /sys/fs/cgroup/cpu/limited/cpu.shares
```

#### Reserve CPU for System Processes:
```bash
# Create a cgroup for user applications with 90% CPU limit
sudo cgcreate -g cpu:/user_apps
echo 900000 | sudo tee /sys/fs/cgroup/cpu/user_apps/cpu.cfs_quota_us
echo 1000000 | sudo tee /sys/fs/cgroup/cpu/user_apps/cpu.cfs_period_us

# This leaves ~10% CPU available for system processes
```

---

### Strategy 2: Using systemd Resource Controls

**Best for:** Managing services on modern Linux distributions

#### Limit CPU for a specific service:
```bash
# Create override file
sudo systemctl edit myservice.service
```

Add the following:
```ini
[Service]
# Limit to 200% CPU (2 full cores max)
CPUQuota=200%

# Set relative CPU weight (default is 100)
CPUWeight=50

# Limit memory as well
MemoryLimit=2G
```

Apply changes:
```bash
sudo systemctl daemon-reload
sudo systemctl restart myservice.service
```

#### Reserve CPU for critical system services:
```bash
# Give SSH service higher priority
sudo systemctl edit sshd.service
```

```ini
[Service]
CPUWeight=200
OOMScoreAdjust=-1000
```

---

### Strategy 3: CPU Pinning (isolcpus)

**Best for:** Dedicated CPU cores for critical processes

#### Isolate CPU cores at boot:
Edit `/etc/default/grub`:
```bash
GRUB_CMDLINE_LINUX="isolcpus=0,1"
```

Update grub and reboot:
```bash
sudo update-grub
sudo reboot
```

#### Pin processes to specific CPUs:
```bash
# Run process on isolated CPUs 0 and 1
taskset -c 0,1 my_critical_process

# Reserve CPU 0 for system/SSH access
# Run all heavy workloads on CPUs 1-N
```

---

### Strategy 4: Process Priorities (nice/renice)

**Best for:** Quick adjustments and background tasks

#### Start process with lower priority:
```bash
# Niceness from -20 (highest) to 19 (lowest)
# Default is 0
nice -n 10 ./my_script.sh

# Very low priority (background task)
nice -n 19 ./background_job.sh
```

#### Change priority of running process:
```bash
# Find PID
ps aux | grep my_process

# Lower priority (requires root for negative values)
sudo renice 15 -p <PID>

# Increase priority (root only)
sudo renice -10 -p <PID>
```

---

### Strategy 5: cpulimit Tool

**Best for:** Strict percentage-based CPU limits

#### Install:
```bash
sudo apt install cpulimit
```

#### Usage:
```bash
# Limit process to 50% CPU
sudo cpulimit -p <PID> -l 50

# Start process with limit
cpulimit -l 25 -- my_command

# Limit by process name
cpulimit -e firefox -l 50
```

---

## Docker-Specific Resource Limits

### Why Docker CPU Limits Matter

Without limits, a single container can:
- Consume 100% of host CPU
- Starve other containers
- Make the host system unresponsive
- Prevent SSH access and diagnostics

### Docker CPU Limit Options

#### 1. CPU Shares (Relative Priority)
```bash
# Default is 1024
# Container with 512 shares gets half the CPU time during contention
docker run --cpu-shares=512 myimage

# In docker-compose.yml:
services:
  myservice:
    cpu_shares: 512
```

#### 2. CPU Quota (Hard Limit)
```bash
# Limit to 50% of one CPU
docker run --cpu-quota=50000 --cpu-period=100000 myimage

# Limit to 1.5 CPUs
docker run --cpus=1.5 myimage

# In docker-compose.yml:
services:
  myservice:
    cpus: 1.5
```

#### 3. CPU Pinning
```bash
# Run on CPUs 0 and 1 only
docker run --cpuset-cpus="0,1" myimage

# In docker-compose.yml:
services:
  myservice:
    cpuset: "0,1"
```

### Example: AFFiNE Docker Compose with CPU Limits

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    deploy:
      resources:
        limits:
          cpus: '1.0'      # Max 1 CPU
          memory: 2G
        reservations:
          cpus: '0.5'      # Guaranteed 0.5 CPU
          memory: 1G
    cpu_shares: 1024       # Default priority

  redis:
    image: redis:7-alpine
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
    cpu_shares: 512        # Lower priority

  affine:
    build: .
    deploy:
      resources:
        limits:
          cpus: '2.0'      # Max 2 CPUs
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G
    cpu_shares: 2048       # Higher priority

  # Reserve resources for system/monitoring
  # Total limits: 1 + 0.5 + 2 = 3.5 CPUs
  # On a 4-core system, this leaves 0.5 CPU for host
```

### Docker Compose v3 Resource Limits

```yaml
version: '3.8'

services:
  backend:
    image: myapp
    deploy:
      resources:
        limits:
          cpus: '1.5'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 1G
```

### Docker Run Command Examples

```bash
# Limit to 1 CPU and 2GB RAM
docker run -d \
  --cpus=1.0 \
  --memory=2g \
  --memory-swap=2g \
  myimage

# Reserve 50% CPU, limit to 150%
docker run -d \
  --cpus=1.5 \
  --cpu-shares=512 \
  myimage
```

---

## Monitoring & Detection

### Real-Time Monitoring

#### 1. htop (Interactive Process Viewer)
```bash
sudo apt install htop
htop

# Sort by CPU: F6 -> CPU%
# Kill process: F9
# Nice value: F7/F8
```

#### 2. top
```bash
top

# Press '1' to show individual CPUs
# Press 'P' to sort by CPU
# Press 'M' to sort by memory
# Press 'k' to kill a process
```

#### 3. Docker Stats
```bash
# Real-time container resource usage
docker stats

# Specific container
docker stats <container_name>

# Format output
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### System Resource Checks

```bash
# CPU info
nproc                    # Number of CPUs
lscpu                    # Detailed CPU info

# Memory info
free -h                  # Human-readable memory
cat /proc/meminfo        # Detailed memory info

# Load average
uptime
cat /proc/loadavg

# Process tree
pstree -p

# Find CPU-intensive processes
ps aux --sort=-%cpu | head -10

# Find memory-intensive processes
ps aux --sort=-%mem | head -10
```

### Automated Monitoring & Alerts

#### Using Prometheus + Grafana

```yaml
# docker-compose.yml
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

  node-exporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"
```

#### Alert on High CPU Usage

```yaml
# prometheus.yml
groups:
  - name: cpu_alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage detected"
          description: "CPU usage is above 80% for 5 minutes"
```

---

## OOM Killer Prevention

### Understanding OOM Killer

The Linux OOM (Out Of Memory) killer terminates processes when the system runs out of memory. This can kill critical processes and cause system instability.

### Prevention Strategies

#### 1. Increase Swap Space
```bash
# Create 4GB swap file
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify
free -h
```

#### 2. Configure OOM Score
```bash
# Protect critical processes (lower score = less likely to be killed)
# -1000 to 1000 range

# Protect SSH daemon
echo -1000 | sudo tee /proc/$(pgrep sshd | head -1)/oom_score_adj

# In systemd service:
[Service]
OOMScoreAdjust=-1000
```

#### 3. Memory Limits with cgroups
```bash
# Limit memory for a cgroup
echo 2G | sudo tee /sys/fs/cgroup/memory/limited/memory.limit_in_bytes

# Set memory+swap limit
echo 3G | sudo tee /sys/fs/cgroup/memory/limited/memory.memsw.limit_in_bytes
```

#### 4. Kernel Parameters
```bash
# Edit /etc/sysctl.conf

# Disable memory overcommit (safer but may cause allocation failures)
vm.overcommit_memory=2
vm.overcommit_ratio=80

# Panic on OOM instead of killing processes (for HA systems)
vm.panic_on_oom=1
kernel.panic=10  # Reboot after 10 seconds

# Apply changes
sudo sysctl -p
```

#### 5. Docker Memory Limits
```bash
# Limit container memory
docker run -d \
  --memory=2g \
  --memory-swap=2g \
  --oom-kill-disable=false \
  myimage

# In docker-compose.yml:
services:
  myservice:
    mem_limit: 2g
    memswap_limit: 2g
```

---

## Practical Implementation Examples

### Example 1: Reserve 10% CPU for System on 4-Core Server

```bash
#!/bin/bash
# reserve-cpu-for-system.sh

# Create cgroup for user applications
sudo cgcreate -g cpu:/user_apps

# On a 4-core system (400% CPU total)
# Reserve 360% for user apps, leaving 40% (10%) for system
sudo bash -c 'echo 3600000 > /sys/fs/cgroup/cpu/user_apps/cpu.cfs_quota_us'
sudo bash -c 'echo 1000000 > /sys/fs/cgroup/cpu/user_apps/cpu.cfs_period_us'

# Move all user processes to this cgroup
# (Requires additional configuration in /etc/cgconfig.conf and /etc/cgrules.conf)
```

### Example 2: Docker Compose with Resource Limits

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 2G
        reservations:
          cpus: '0.25'
          memory: 512M
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.1'
          memory: 128M
    restart: unless-stopped

  backend:
    build: .
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '0.5'
          memory: 1G
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

# Total: 3.5 CPU limit on 4-core system = 0.5 CPU reserved for host
```

### Example 3: Emergency Diagnostic Script

```bash
#!/bin/bash
# emergency-diagnostics.sh
# Run this when server is hanging to diagnose issues

echo "=== System Load ==="
uptime

echo -e "\n=== CPU Usage ==="
top -bn1 | head -20

echo -e "\n=== Memory Usage ==="
free -h

echo -e "\n=== Disk Usage ==="
df -h

echo -e "\n=== Top CPU Processes ==="
ps aux --sort=-%cpu | head -10

echo -e "\n=== Top Memory Processes ==="
ps aux --sort=-%mem | head -10

echo -e "\n=== Docker Container Stats ==="
docker stats --no-stream

echo -e "\n=== Recent OOM Kills ==="
dmesg | grep -i "killed process" | tail -10

echo -e "\n=== Network Connections ==="
ss -tunap | wc -l
echo "Total connections"

echo -e "\n=== Disk I/O ==="
iostat -x 1 3
```

### Example 4: Systemd Service with Resource Limits

```ini
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application
After=network.target

[Service]
Type=simple
User=myapp
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/start.sh

# Resource Limits
CPUQuota=150%              # Max 1.5 CPUs
CPUWeight=100              # Default priority
MemoryLimit=2G             # Max 2GB RAM
MemoryHigh=1.5G            # Soft limit (throttle at 1.5GB)
TasksMax=200               # Max 200 processes/threads

# OOM Protection
OOMScoreAdjust=500         # More likely to be killed than system services

# I/O Limits
IOWeight=100               # Default I/O priority

Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
```

### Example 5: I/O Priority Management

```bash
# Run backup with lowest I/O priority
ionice -c 3 rsync -av /data /backup

# Run database with high I/O priority
ionice -c 2 -n 0 postgres

# Check I/O priority of running process
ionice -p <PID>

# Combine with CPU nice
nice -n 10 ionice -c 3 ./background-task.sh
```

---

## Quick Reference Commands

### Diagnose Hanging Server
```bash
# Check load
uptime

# Check CPU usage
top -bn1 | head -20

# Check memory
free -h

# Check disk I/O
iostat -x 1 5

# Check network
ss -s

# Check Docker
docker stats --no-stream

# Find runaway processes
ps aux --sort=-%cpu | head -10
```

### Apply Resource Limits
```bash
# Limit running process CPU
cpulimit -p <PID> -l 50

# Change process priority
sudo renice 10 -p <PID>

# Change I/O priority
sudo ionice -c 3 -p <PID>

# Restart Docker container with limits
docker update --cpus=1.0 --memory=2g <container>
```

### Emergency Actions
```bash
# Kill process gracefully
kill <PID>

# Force kill
kill -9 <PID>

# Kill all processes by name
pkill -9 process_name

# Restart Docker container
docker restart <container>

# Stop all Docker containers
docker stop $(docker ps -q)

# Clear page cache (careful!)
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```

---

## Recommendations for Your AFFiNE Deployment

Based on your EC2 setup, here are specific recommendations:

### 1. Check Current Resources
```bash
ssh aws-kacperjakub2099 "nproc && free -h"
```

### 2. Add Resource Limits to docker-compose.yml
```yaml
services:
  postgres:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 2G

  redis:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

  affine:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
```

### 3. Monitor with Docker Stats
```bash
# Add to your deployment script
docker stats --no-stream
```

### 4. Set Up Swap (if not already configured)
```bash
ssh aws-kacperjakub2099 "sudo fallocate -l 4G /swapfile && \
  sudo chmod 600 /swapfile && \
  sudo mkswap /swapfile && \
  sudo swapon /swapfile"
```

### 5. Create Emergency Diagnostic Script
Save the emergency-diagnostics.sh script above and run it when needed.

---

## Conclusion

**Yes, you can and should reserve CPU resources** for system processes and diagnostics. The best approaches are:

1. **Docker CPU limits** - Easiest for containerized apps
2. **systemd resource controls** - Best for services
3. **cgroups** - Most flexible and powerful
4. **CPU pinning** - For dedicated cores

**Key Takeaway:** Always leave at least 10-20% of CPU unreserved so you can SSH in and diagnose issues when the server is under heavy load.
