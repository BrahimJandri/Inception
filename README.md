# Docker & Inception Project Documentation
## Complete Guide to Understanding Docker Technology and Implementation

---

# Table of Contents

1. [What is Docker?](#what-is-docker)
2. [How Docker Works](#how-docker-works)
3. [Docker Architecture](#docker-architecture)
4. [Docker Images](#docker-images)
5. [Docker Containers](#docker-containers)
6. [Dockerfile Deep Dive](#dockerfile-deep-dive)
7. [Docker Compose](#docker-compose)
8. [Docker Networking](#docker-networking)
9. [Docker Volumes](#docker-volumes)
10. [Security in Docker](#security-in-docker)
11. [Inception Project Requirements](#inception-project-requirements)
12. [Implementation Guide](#implementation-guide)

---

## What is Docker?

### Definition
Docker is a containerization platform that enables developers to package applications and their dependencies into lightweight, portable containers. These containers can run consistently across different environments.

### Key Concepts

#### Containerization vs Virtualization

**Traditional Virtual Machines:**
```
┌─────────────────────────────────────┐
│            Application              │
├─────────────────────────────────────┤
│               Guest OS              │
├─────────────────────────────────────┤
│            Hypervisor              │
├─────────────────────────────────────┤
│              Host OS               │
└─────────────────────────────────────┘
```

**Docker Containers:**
```
┌─────────────────────────────────────┐
│            Application              │
├─────────────────────────────────────┤
│           Docker Engine             │
├─────────────────────────────────────┤
│              Host OS               │
└─────────────────────────────────────┘
```

#### Benefits of Docker
- **Lightweight**: Containers share the host OS kernel
- **Fast startup**: No OS boot time required
- **Consistent**: Same environment across development, testing, and production
- **Scalable**: Easy to scale applications horizontally
- **Portable**: Run anywhere Docker is supported

---

## How Docker Works

### Linux Kernel Features

Docker leverages several Linux kernel features to provide isolation and resource management:

#### 1. Namespaces
Namespaces provide isolation for various system resources:

**PID Namespace**: Process isolation
```bash
# Inside container: processes start from PID 1
ps aux
# PID    COMMAND
# 1      /bin/sh
# 15     ps aux

# On host: same processes have different PIDs
ps aux | grep container_process
# PID    COMMAND  
# 1234   /bin/sh (from container)
```

**Network Namespace**: Network isolation
```bash
# Container has its own network interfaces
ip addr show
# 1: lo: <LOOPBACK,UP,LOWER_UP>
# 2: eth0@if123: <BROADCAST,MULTICAST,UP,LOWER_UP>
```

**Mount Namespace**: Filesystem isolation
```bash
# Container sees its own filesystem view
mount | grep overlay
# overlay on / type overlay (rw,relatime,lowerdir=...)
```

**User Namespace**: User ID isolation
```bash
# User appears as root inside container but mapped to regular user on host
id
# uid=0(root) gid=0(root) groups=0(root)
```

#### 2. Control Groups (cgroups)
cgroups limit and account for resource usage:

```bash
# Memory limit
echo "128M" > /sys/fs/cgroup/memory/docker/container_id/memory.limit_in_bytes

# CPU limit  
echo "50000" > /sys/fs/cgroup/cpu/docker/container_id/cpu.cfs_quota_us
```

#### 3. Union File Systems
Layered filesystem that allows multiple directories to be mounted as one:

```
┌─────────────────┐  ← Container Layer (Read/Write)
├─────────────────┤  ← Image Layer 3 (Read Only)  
├─────────────────┤  ← Image Layer 2 (Read Only)
├─────────────────┤  ← Image Layer 1 (Read Only)
└─────────────────┘  ← Base Image Layer (Read Only)
```

---

## Docker Architecture

### Components Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Docker Client  │◄──►│  Docker Daemon  │◄──►│ Container Runtime│
│     (CLI)       │    │   (dockerd)     │    │   (containerd)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│    Commands     │    │     Images      │    │   Containers    │
│   (build,run)   │    │   (storage)     │    │   (execution)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

#### Docker Client
- Command-line interface (CLI)
- Communicates with Docker daemon via REST API
- Can connect to local or remote daemon

#### Docker Daemon (dockerd)
- Background service running on host
- Manages Docker objects (images, containers, networks, volumes)
- Listens for Docker API requests
- Handles container lifecycle

#### Container Runtime
**containerd**: High-level runtime
- Manages container lifecycle
- Handles image transfers and storage
- Supervises container execution

**runc**: Low-level runtime
- OCI (Open Container Initiative) compliant
- Actually creates and runs containers
- Interfaces directly with kernel features

### Communication Flow
```
1. docker run nginx
   ↓
2. Docker Client → Docker Daemon (API call)
   ↓
3. Docker Daemon → containerd (container management)
   ↓
4. containerd → runc (container execution)
   ↓
5. runc → Linux Kernel (namespaces, cgroups)
```

---

## Docker Images

### What is a Docker Image?

A Docker image is a read-only template used to create containers. It consists of:
- Application code
- Runtime environment
- System tools
- Libraries
- Dependencies
- Configuration files

### Image Layers

Images are built using a layered architecture:

```dockerfile
FROM ubuntu:20.04           # Base layer
RUN apt-get update          # Layer 1
RUN apt-get install nginx   # Layer 2  
COPY index.html /var/www/   # Layer 3
CMD ["nginx", "-g", "daemon off;"]  # Layer 4 (metadata)
```

**Benefits of Layers:**
- **Reusability**: Layers can be shared across images
- **Caching**: Unchanged layers don't need rebuilding
- **Storage efficiency**: Deduplication saves disk space

### Image Storage

**Location**: `/var/lib/docker/`
```bash
# Image layers stored here
/var/lib/docker/overlay2/
/var/lib/docker/image/overlay2/
```

**Image Manifest**: JSON file containing:
```json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
  "config": {
    "digest": "sha256:abc123...",
    "mediaType": "application/vnd.docker.container.image.v1+json"
  },
  "layers": [
    {
      "digest": "sha256:def456...",
      "mediaType": "application/vnd.docker.image.rootfs.diff.tar.gzip"
    }
  ]
}
```

---

## Docker Containers

### Container Lifecycle

```
┌─────────┐ create ┌─────────┐ start ┌─────────┐
│ Created │───────→│ Created │──────→│ Running │
└─────────┘        └─────────┘       └─────────┘
                            ▲               │
                     restart │               │ stop/kill
                            │               ▼
                   ┌─────────┐      ┌─────────┐ remove ┌─────────┐
                   │ Exited  │◄─────│ Exited  │───────→│ Deleted │
                   └─────────┘      └─────────┘        └─────────┘
```

### Container States

**Created**: Container exists but hasn't been started
```bash
docker create --name myapp nginx:alpine
docker ps -a  # Shows created containers
```

**Running**: Container is actively executing
```bash
docker start myapp
docker ps  # Shows only running containers
```

**Paused**: Container processes are frozen
```bash
docker pause myapp
# Processes suspended using cgroups freezer
```

**Stopped**: Container has exited
```bash
docker stop myapp  # Sends SIGTERM, then SIGKILL
docker kill myapp  # Sends SIGKILL immediately
```

### Container Isolation

Each container gets its own:
- Process tree (PID namespace)
- Network interfaces (Network namespace)  
- Filesystem view (Mount namespace)
- User IDs (User namespace)
- Hostname (UTS namespace)
- Inter-process communication (IPC namespace)

---

## Dockerfile Deep Dive

### Dockerfile Instructions

#### FROM
Specifies the base image:
```dockerfile
FROM alpine:3.18
FROM ubuntu:20.04  
FROM scratch  # Empty base image
```

#### RUN  
Executes commands during image build:
```dockerfile
# Shell form (uses /bin/sh -c)
RUN apt-get update && apt-get install -y nginx

# Exec form (no shell processing)
RUN ["apt-get", "update"]
```

#### COPY vs ADD
**COPY**: Simple file/directory copying
```dockerfile
COPY src/ /app/
COPY config.json /app/config.json
```

**ADD**: Extended functionality (URLs, auto-extraction)
```dockerfile
ADD https://example.com/file.tar.gz /tmp/
ADD archive.tar.gz /app/  # Auto-extracts
```

#### WORKDIR
Sets working directory:
```dockerfile
WORKDIR /app
RUN pwd  # Outputs: /app
```

#### EXPOSE
Documents port usage (metadata only):
```dockerfile
EXPOSE 80
EXPOSE 443/tcp
EXPOSE 53/udp
```

#### ENV
Sets environment variables:
```dockerfile
ENV NODE_ENV=production
ENV PATH="/app/bin:${PATH}"
```

#### ARG
Build-time variables:
```dockerfile
ARG VERSION=1.0
RUN echo "Building version ${VERSION}"
```

#### USER
Sets user context:
```dockerfile
RUN adduser -D -s /bin/sh appuser
USER appuser
```

#### CMD vs ENTRYPOINT
**CMD**: Default command (can be overridden)
```dockerfile
CMD ["nginx", "-g", "daemon off;"]
# docker run myimage /bin/sh  # Overrides CMD
```

**ENTRYPOINT**: Always executed (parameters appended)
```dockerfile
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
# docker run myimage -t  # Runs: nginx -t
```

### Best Practices

#### 1. Multi-stage Builds
```dockerfile
# Build stage
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

#### 2. Layer Optimization
```dockerfile
# Bad: Multiple layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get clean

# Good: Single layer
RUN apt-get update && \
    apt-get install -y curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

#### 3. Security Practices
```dockerfile
# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Set ownership
COPY --chown=appuser:appgroup . /app

# Switch to non-root user
USER appuser
```

#### 4. .dockerignore
```
node_modules
*.log
.git
.env
Dockerfile
README.md
```

---

## Docker Compose

### What is Docker Compose?

Docker Compose is a tool for defining and running multi-container Docker applications using YAML configuration files.

### Compose File Structure

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - db
    environment:
      - NODE_ENV=production
    networks:
      - app-network
    volumes:
      - ./src:/app/src

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=myapp
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - app-network

volumes:
  db-data:

networks:
  app-network:
    driver: bridge
```

### Service Configuration

#### Build Context
```yaml
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.prod
      args:
        - VERSION=1.0
```

#### Image
```yaml
services:
  web:
    image: nginx:alpine
    # OR
    image: myregistry.com/myapp:latest
```

#### Ports
```yaml
services:
  web:
    ports:
      - "80:80"        # host:container
      - "443:443"
      - "127.0.0.1:8080:8080"  # Bind to specific interface
```

#### Environment Variables
```yaml
services:
  app:
    environment:
      - NODE_ENV=production
      - DEBUG=false
    # OR
    env_file:
      - .env
      - .env.prod
```

#### Dependencies
```yaml
services:
  web:
    depends_on:
      - db
      - redis
  
  # With health checks
  web:
    depends_on:
      db:
        condition: service_healthy
```

#### Restart Policies
```yaml
services:
  app:
    restart: always         # Always restart
    # restart: unless-stopped # Restart unless manually stopped
    # restart: on-failure    # Restart on non-zero exit
    # restart: no           # Never restart (default)
```

### Networks in Compose

#### Default Network
```yaml
# Compose automatically creates a default network
services:
  web:
    # Automatically joins default network
  db:
    # Can communicate with 'web' service by name
```

#### Custom Networks
```yaml
services:
  frontend:
    networks:
      - frontend-net
      - backend-net
  
  backend:
    networks:
      - backend-net
  
  database:
    networks:
      - backend-net

networks:
  frontend-net:
    driver: bridge
  backend-net:
    driver: bridge
    internal: true  # No external access
```

### Volumes in Compose

#### Named Volumes
```yaml
services:
  db:
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:  # Docker-managed volume
```

#### Bind Mounts
```yaml
services:
  web:
    volumes:
      - ./src:/app/src                    # Relative path
      - /host/path:/container/path        # Absolute path
      - ./config:/app/config:ro           # Read-only
```

### Compose Commands

```bash
# Start services
docker-compose up -d

# Scale services
docker-compose up -d --scale web=3

# View logs
docker-compose logs web
docker-compose logs -f  # Follow logs

# Execute commands
docker-compose exec web bash

# Stop services
docker-compose down

# Remove everything including volumes
docker-compose down -v
```

---

## Docker Networking

### Network Drivers

#### Bridge (Default)
```bash
# Default bridge network
docker network ls
# NETWORK ID     NAME      DRIVER    SCOPE
# 12345abc       bridge    bridge    local
```

**Characteristics:**
- Containers can communicate with each other
- NAT for external communication
- Automatic DNS resolution by container name

#### Host
```bash
docker run --network host nginx
```
- Container uses host's network stack
- No network isolation
- Performance benefits for high-traffic applications

#### None
```bash
docker run --network none alpine
```
- No network access
- Complete network isolation
- Useful for security-sensitive applications

### Custom Networks

#### Creating Networks
```bash
# Create bridge network
docker network create --driver bridge mynetwork

# Create with custom subnet
docker network create --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  mynetwork
```

#### Network Communication
```yaml
# docker-compose.yml
services:
  web:
    image: nginx
    networks:
      - frontend
  
  api:
    image: node:alpine
    networks:
      - frontend
      - backend
  
  db:
    image: postgres
    networks:
      - backend

networks:
  frontend:
  backend:
    internal: true  # No internet access
```

### DNS Resolution

**Automatic Service Discovery:**
```bash
# Inside web container
curl http://api:3000/users    # Resolves 'api' to API container IP
ping db                       # Can ping database by service name
```

**Custom DNS:**
```yaml
services:
  web:
    dns:
      - 8.8.8.8
      - 1.1.1.1
    dns_search:
      - example.com
```

---

## Docker Volumes

### Volume Types

#### Named Volumes (Docker-managed)
```bash
# Create volume
docker volume create myvolume

# Use in container
docker run -v myvolume:/data alpine

# Inspect volume
docker volume inspect myvolume
```

**Storage Location**: `/var/lib/docker/volumes/`

#### Bind Mounts (Host-managed)
```bash
# Mount host directory
docker run -v /host/path:/container/path alpine

# Mount with options
docker run -v /host/path:/container/path:ro alpine  # Read-only
```

#### tmpfs Mounts (Memory-based)
```bash
# Create tmpfs mount
docker run --tmpfs /tmp alpine

# With size limit
docker run --tmpfs /tmp:size=100m alpine
```

### Volume Management

#### Backup and Restore
```bash
# Backup volume
docker run --rm -v myvolume:/data -v $(pwd):/backup alpine \
  tar czf /backup/backup.tar.gz -C /data .

# Restore volume
docker run --rm -v myvolume:/data -v $(pwd):/backup alpine \
  tar xzf /backup/backup.tar.gz -C /data
```

#### Volume Drivers
```bash
# Local driver (default)
docker volume create --driver local myvolume

# NFS driver
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/dir \
  nfs-volume
```

---

## Security in Docker

### Container Security Principles

#### Principle of Least Privilege
```dockerfile
# Create minimal user
FROM alpine:3.18
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup
USER appuser
```

#### Read-only Root Filesystem
```bash
docker run --read-only --tmpfs /tmp nginx
```

#### Drop Capabilities
```bash
# Drop all capabilities except NET_BIND_SERVICE
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE nginx
```

### Secrets Management

#### Docker Secrets (Swarm mode)
```yaml
version: '3.8'
services:
  db:
    image: postgres
    secrets:
      - db_password
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password

secrets:
  db_password:
    file: ./db_password.txt
```

#### Environment Files
```bash
# .env file
DB_PASSWORD=secret123
API_KEY=abc123

# docker-compose.yml
services:
  app:
    env_file:
      - .env
```

### Security Scanning

```bash
# Scan image for vulnerabilities
docker scan myimage:latest

# Use security benchmark
docker run --rm --net host --pid host --cap-add audit_control \
  -v /etc:/etc:ro \
  -v /usr/bin/docker-containerd:/usr/bin/docker-containerd:ro \
  -v /usr/bin/docker-runc:/usr/bin/docker-runc:ro \
  -v /usr/lib/systemd:/usr/lib/systemd:ro \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --label docker_bench_security \
  docker/docker-bench-security
```

---

## Inception Project Requirements

### Project Overview

**Objective**: Set up a small infrastructure with different services using Docker Compose in a virtual machine.

### Mandatory Requirements

#### Infrastructure Components
1. **NGINX Container**
   - TLSv1.2 or TLSv1.3 only
   - Sole entry point (port 443 only)
   - SSL/TLS termination

2. **WordPress Container**  
   - PHP-FPM only (no nginx)
   - WordPress installation and configuration
   - Database connectivity

3. **MariaDB Container**
   - Database service only (no nginx)
   - WordPress database storage
   - Persistent data

#### Networking
- Custom Docker network required
- No `network: host`, `--link`, or `links:` allowed
- Internal service communication only
- Only NGINX accessible externally

#### Storage
- WordPress database volume
- WordPress files volume  
- Volumes in `/home/login/data/` on host

#### Configuration
- Domain: `login.42.fr` (replace with your login)
- No passwords in Dockerfiles
- Environment variables mandatory
- `.env` file recommended
- Docker secrets for sensitive data

#### Restrictions
- **Forbidden**: 
  - `tail -f`, `bash`, `sleep infinity`, `while true`
  - Ready-made images from DockerHub (except Alpine/Debian)
  - `latest` tag
  - Admin usernames containing 'admin'

- **Required**:
  - Custom Dockerfiles for each service
  - Alpine or Debian base images only
  - Automatic restart on crash
  - Proper PID 1 handling

### Directory Structure
```
inception/
├── Makefile
├── secrets/
│   ├── credentials.txt
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf
        │   └── tools/
        │       └── setup.sh
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── wp-config.php
        │   └── tools/
        │       └── setup.sh
        └── mariadb/
            ├── Dockerfile
            ├── conf/
            │   └── my.cnf
            └── tools/
                └── setup.sh
```

---

## Implementation Guide

### Step 1: Environment Setup

#### Host Configuration
```bash
# Add domain to hosts file
echo "127.0.0.1 login.42.fr" >> /etc/hosts

# Create data directories
mkdir -p /home/$USER/data/wordpress
mkdir -p /home/$USER/data/mariadb
```

#### .env File
```bash
# srcs/.env
DOMAIN_NAME=login.42.fr

# Database Configuration
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=secure_wp_password

# WordPress Configuration
WP_ADMIN_USER=admin_user
WP_ADMIN_PASSWORD=admin_password
WP_ADMIN_EMAIL=admin@example.com
WP_USER=regular_user
WP_USER_PASSWORD=user_password
WP_USER_EMAIL=user@example.com

# Paths
WP_DATA_PATH=/home/${USER}/data/wordpress
DB_DATA_PATH=/home/${USER}/data/mariadb
```

### Step 2: MariaDB Container

#### Dockerfile
```dockerfile
FROM debian:bullseye-slim

# Install MariaDB
RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY conf/my.cnf /etc/mysql/my.cnf

# Copy initialization script
COPY tools/init-db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init-db.sh

# Create mysql user and set permissions
RUN usermod -u 999 mysql && \
    groupmod -g 999 mysql && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# Expose port
EXPOSE 3306

# Set user
USER mysql

# Start MariaDB
CMD ["/usr/local/bin/init-db.sh"]
```

#### Configuration (conf/my.cnf)
```ini
[mysqld]
bind-address = 0.0.0.0
port = 3306
socket = /var/run/mysqld/mysqld.sock
datadir = /var/lib/mysql
log-error = /var/log/mysql/error.log
pid-file = /var/run/mysqld/mysqld.pid

# Character set
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Security
skip-networking = false
skip-bind-address = false
```

#### Initialization Script (tools/init-db.sh)
```bash
#!/bin/bash

# Initialize database if not exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MySQL in background
mysqld_safe --datadir='/var/lib/mysql' &

# Wait for MySQL to start
while ! mysqladmin ping -h localhost --silent; do
    sleep 1
done

# Run initialization SQL
mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# Stop background MySQL
mysqladmin shutdown -u root -p${MYSQL_ROOT_PASSWORD}

# Start MySQL in foreground
exec mysqld --user=mysql --datadir=/var/lib/mysql
```

### Step 3: WordPress Container

#### Dockerfile
```dockerfile
FROM debian:bullseye-slim

# Install PHP-FPM and dependencies
RUN apt-get update && \
    apt-get install -y \
        php7.4-fpm \
        php7.4-mysql \
        php7.4-curl \
        php7.4-gd \
        php7.4-mbstring \
        php7.4-xml \
        php7.4-zip \
        wget \
        unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Download WordPress
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz && \
    tar xzf /tmp/wordpress.tar.gz -C /var/www && \
    rm /tmp/wordpress.tar.gz && \
    chown -R www-data:www-data /var/www/wordpress

# Copy configuration files
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

# Create directories
RUN mkdir -p /var/run/php && \
    chown www-data:www-data /var/run/php

# Expose port
EXPOSE 9000

# Set user
USER www-data

# Start PHP-FPM
CMD ["/usr/local/bin/setup.sh"]
```

#### PHP-FPM Configuration (conf/www.conf)
```ini
[www]
user = www-data
group = www-data
listen = 9000
listen.owner = www-data
listen.group = www-data
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
```

#### Setup Script (tools/setup.sh)
```bash
#!/bin/bash

# Wait for database
while ! nc -z mariadb 3306; do
    sleep 1
done

# Create wp-config.php if not exists
if [ ! -f "/var/www/wordpress/wp-config.php" ]; then
    cat > /var/www/wordpress/wp-config.php << EOF
<?php
define('DB_NAME', '${MYSQL_DATABASE}');
define('DB_USER', '${MYSQL_USER}');
define('DB_PASSWORD', '${MYSQL_PASSWORD}');
define('DB_HOST', 'mariadb');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

\$table_prefix = 'wp_';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOF
fi

# Install WordPress CLI
if [ ! -f "/usr/local/bin/wp" ]; then
    wget https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/wp-cli.phar -O /tmp/wp-cli.phar
    chmod +x /tmp/wp-cli.phar
    mv /tmp/wp-cli.phar /usr/local/bin/wp
fi

# Install WordPress
cd /var/www/wordpress
if ! wp core is-installed --allow-root; then
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception Blog" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    # Create additional user
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author \
        --allow-root
fi

# Start PHP-FPM
exec php-fpm7.4 -F
```

### Step 4: NGINX Container

#### Dockerfile
```dockerfile
FROM debian:bullseye-slim

# Install NGINX and OpenSSL
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

# Create directories
RUN mkdir -p /var/run/nginx /var/log/nginx /etc/nginx/ssl

# Create nginx user
RUN useradd -r -s /bin/false nginx

# Expose port
EXPOSE 443

#### NGINX Configuration (conf/nginx.conf)
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;

    # Security Headers
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";

    server {
        listen 443 ssl http2;
        server_name ${DOMAIN_NAME};
        
        root /var/www/wordpress;
        index index.php index.html index.htm;

        # SSL Certificate
        ssl_certificate /etc/nginx/ssl/cert.crt;
        ssl_certificate_key /etc/nginx/ssl/cert.key;

        # Security
        server_tokens off;

        # WordPress specific configuration
        location / {
            try_files $uri $uri/ /index.php?$args;
        }

        location ~ \.php$ {
            include fastcgi_params;
            fastcgi_intercept_errors on;
            fastcgi_pass wordpress:9000;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }

        location ~ /\.ht {
            deny all;
        }

        location = /favicon.ico {
            log_not_found off;
            access_log off;
        }

        location = /robots.txt {
            log_not_found off;
            access_log off;
            allow all;
        }

        location ~* \.(css|gif|ico|jpeg|jpg|js|png)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }
}
```

#### Setup Script (tools/setup.sh)
```bash
#!/bin/bash

# Generate SSL certificate if not exists
if [ ! -f "/etc/nginx/ssl/cert.crt" ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/cert.key \
        -out /etc/nginx/ssl/cert.crt \
        -subj "/C=MA/ST=Marrakesh/L=Benguerir/O=42School/CN=${DOMAIN_NAME}"
    
    chmod 600 /etc/nginx/ssl/cert.key
    chmod 644 /etc/nginx/ssl/cert.crt
fi

# Replace environment variables in nginx config
envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf > /tmp/nginx.conf
mv /tmp/nginx.conf /etc/nginx/nginx.conf

# Test nginx configuration
nginx -t

# Start nginx in foreground
exec nginx -g "daemon off;"
```

### Step 5: Docker Compose Configuration

#### docker-compose.yml
```yaml
version: '3.8'

services:
  mariadb:
    build:
      context: ./requirements/mariadb
      dockerfile: Dockerfile
    container_name: mariadb
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - inception-network
    restart: always
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-p${MYSQL_ROOT_PASSWORD}"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 30s

  wordpress:
    build:
      context: ./requirements/wordpress
      dockerfile: Dockerfile
    container_name: wordpress
    environment:
      - MYSQL_DATABASE=${MYSQL_DATABASE}
      - MYSQL_USER=${MYSQL_USER}
      - MYSQL_PASSWORD=${MYSQL_PASSWORD}
      - DOMAIN_NAME=${DOMAIN_NAME}
      - WP_ADMIN_USER=${WP_ADMIN_USER}
      - WP_ADMIN_PASSWORD=${WP_ADMIN_PASSWORD}
      - WP_ADMIN_EMAIL=${WP_ADMIN_EMAIL}
      - WP_USER=${WP_USER}
      - WP_USER_PASSWORD=${WP_USER_PASSWORD}
      - WP_USER_EMAIL=${WP_USER_EMAIL}
    volumes:
      - wordpress_data:/var/www/wordpress
    networks:
      - inception-network
    depends_on:
      mariadb:
        condition: service_healthy
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "nc -z localhost 9000 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3

  nginx:
    build:
      context: ./requirements/nginx
      dockerfile: Dockerfile
    container_name: nginx
    environment:
      - DOMAIN_NAME=${DOMAIN_NAME}
    ports:
      - "443:443"
    volumes:
      - wordpress_data:/var/www/wordpress
    networks:
      - inception-network
    depends_on:
      wordpress:
        condition: service_healthy
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "curl -k https://localhost:443 || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${DB_DATA_PATH}
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ${WP_DATA_PATH}

networks:
  inception-network:
    driver: bridge
    name: inception-network
```

### Step 6: Makefile

```makefile
# Variables
USER := $(shell whoami)
DATA_DIR := /home/$(USER)/data

# Default target
all: up

# Create data directories
$(DATA_DIR):
	@mkdir -p $(DATA_DIR)/wordpress
	@mkdir -p $(DATA_DIR)/mariadb
	@echo "Data directories created"

# Build and start services
up: $(DATA_DIR)
	@echo "Starting Inception services..."
	@cd srcs && docker-compose up -d --build
	@echo "Services started successfully"
	@echo "Access your site at: https://$(USER).42.fr"

# Stop services
down:
	@echo "Stopping Inception services..."
	@cd srcs && docker-compose down
	@echo "Services stopped"

# Show status
status:
	@cd srcs && docker-compose ps

# Show logs
logs:
	@cd srcs && docker-compose logs -f

# Clean containers and images
clean: down
	@echo "Cleaning containers and images..."
	@docker system prune -af
	@docker volume prune -f
	@echo "Cleanup completed"

# Full cleanup including data
fclean: clean
	@echo "Removing data directories..."
	@sudo rm -rf $(DATA_DIR)
	@echo "Full cleanup completed"

# Restart services
restart: down up

# Rebuild services
rebuild: down
	@cd srcs && docker-compose up -d --build --force-recreate

# Help
help:
	@echo "Available targets:"
	@echo "  up      - Start all services"
	@echo "  down    - Stop all services"
	@echo "  status  - Show service status"
	@echo "  logs    - Show service logs"
	@echo "  clean   - Remove containers and images"
	@echo "  fclean  - Full cleanup including data"
	@echo "  restart - Restart all services"
	@echo "  rebuild - Rebuild and restart services"
	@echo "  help    - Show this help"

.PHONY: all up down status logs clean fclean restart rebuild help
```

### Step 7: Bonus Features

#### Redis Cache
```dockerfile
# requirements/redis/Dockerfile
FROM alpine:3.18

RUN apk add --no-cache redis

COPY conf/redis.conf /etc/redis.conf

EXPOSE 6379

USER redis

CMD ["redis-server", "/etc/redis.conf"]
```

#### FTP Server
```dockerfile
# requirements/ftp/Dockerfile
FROM alpine:3.18

RUN apk add --no-cache vsftpd

COPY conf/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY tools/setup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 21 21000-21010

CMD ["/usr/local/bin/setup.sh"]
```

#### Adminer
```dockerfile
# requirements/adminer/Dockerfile
FROM php:8.1-fpm-alpine

RUN apk add --no-cache wget && \
    wget "https://www.adminer.org/latest.php" -O /var/www/html/index.php && \
    chown -R www-data:www-data /var/www/html

EXPOSE 9000

CMD ["php-fpm"]
```

### Step 8: Security Considerations

#### Secrets Management
```bash
# secrets/db_password.txt
secure_database_password_123

# secrets/db_root_password.txt  
super_secure_root_password_456

# secrets/credentials.txt
admin_user:secure_admin_password
regular_user:secure_user_password
```

#### Environment Variable Security
```bash
# srcs/.env (never commit to git)
# Add to .gitignore
echo ".env" >> .gitignore
echo "secrets/" >> .gitignore
```

#### Docker Security Best Practices
1. **Non-root users in containers**
2. **Read-only filesystems where possible**
3. **Minimal attack surface**
4. **Regular security updates**
5. **Secrets management**
6. **Network segmentation**

### Step 9: Testing and Validation

#### Verification Checklist
```bash
# 1. Check containers are running
docker ps

# 2. Check networks
docker network ls
docker network inspect inception-network

# 3. Check volumes
docker volume ls
ls -la /home/$USER/data/

# 4. Test connectivity
curl -k https://yourusername.42.fr

# 5. Check SSL certificate
openssl s_client -connect yourusername.42.fr:443 -servername yourusername.42.fr

# 6. Verify database connection
docker exec -it mariadb mysql -u root -p

# 7. Check WordPress functionality
# - Login as admin
# - Login as regular user
# - Create/edit posts
# - Upload media
```

#### Performance Testing
```bash
# Load testing with Apache Bench
ab -n 1000 -c 10 https://yourusername.42.fr/

# Monitor resource usage
docker stats

# Check logs for errors
docker-compose logs | grep -i error
```

### Step 10: Troubleshooting Guide

#### Common Issues and Solutions

**Container Won't Start:**
```bash
# Check logs
docker logs container_name

# Check Dockerfile syntax
docker build -t test-image .

# Verify base image
docker pull alpine:3.18
```

**Network Connectivity Issues:**
```bash
# Test internal network
docker exec -it nginx ping wordpress
docker exec -it wordpress ping mariadb

# Check DNS resolution
docker exec -it nginx nslookup wordpress
```

**Volume Mount Issues:**
```bash
# Check permissions
ls -la /home/$USER/data/
sudo chown -R $USER:$USER /home/$USER/data/

# Verify mount points
docker inspect container_name | grep Mounts
```

**SSL Certificate Problems:**
```bash
# Regenerate certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout cert.key -out cert.crt \
  -subj "/CN=yourusername.42.fr"

# Test certificate
openssl x509 -in cert.crt -text -noout
```

**Database Connection Issues:**
```bash
# Check MariaDB status
docker exec -it mariadb mysqladmin ping

# Test connection from WordPress container
docker exec -it wordpress nc -zv mariadb 3306

# Verify credentials
docker exec -it mariadb mysql -u wp_user -p
```

---

## Conclusion

This comprehensive documentation covers everything needed to understand Docker technology and successfully implement the Inception project. The key to success is:

1. **Understanding the fundamentals** - How Docker works under the hood
2. **Following best practices** - Security, performance, and maintainability
3. **Meeting all requirements** - Careful attention to project specifications  
4. **Thorough testing** - Verification and troubleshooting
5. **Documentation** - Clear understanding of what you've built

Remember that Docker is a powerful tool that simplifies application deployment and scaling. The concepts learned in this project apply to real-world containerization scenarios and modern DevOps practices.

Good luck with your Inception project!
