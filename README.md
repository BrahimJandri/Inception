Transforming Ideas into Seamless Digital Realities

![last commit](https://img.shields.io/badge/last%20commit-today-blue?style=for-the-badge)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=for-the-badge&logo=mariadb&logoColor=white)
![WordPress](https://img.shields.io/badge/WordPress-21759B?style=for-the-badge&logo=wordpress&logoColor=white)
![Nginx](https://img.shields.io/badge/NGINX-009639?style=for-the-badge&logo=nginx&logoColor=white)

Built with the tools and technologies:  
![GNU Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
  - [Usage](#usage)
- [Services](#services)
  - [Core Services](#core-services)
  - [Bonus Services](#bonus-services)
- [Project Structure](#project-structure)
- [Makefile Commands](#makefile-commands)
- [Accessing Services](#accessing-services)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](https://github.com/BrahimJandri/Inception/blob/main/License)

---

## Overview

The **Inception** project is a comprehensive Docker-based infrastructure that creates a secure, modular, and reproducible environment for running a complete web stack. This project demonstrates advanced containerization concepts by deploying multiple interconnected services using Docker containers, each following security best practices and configured from scratch.

The infrastructure includes a WordPress website backed by MariaDB, served through NGINX with SSL/TLS encryption, enhanced with Redis caching, and includes additional tools for development and administration.

---

## Features

- **🐳 Containerized Architecture**: All services run in isolated Docker containers
- **🔒 HTTPS/SSL Support**: Secure connections with SSL certificates
- **📊 Database Management**: MariaDB with persistent data storage
- **⚡ Caching**: Redis integration for improved performance
- **📁 File Management**: FTP server for easy file transfers
- **🛠️ Administration Tools**: Adminer for database management, Portainer for container management
- **📱 Static Site**: Custom portfolio/static website
- **🔄 Automated Setup**: Makefile for easy deployment and management
- **💾 Persistent Storage**: Data persistence using Docker volumes

---

## Getting Started

### Prerequisites

Make sure you have the following installed on your system:
- [Docker](https://docs.docker.com/get-docker/) (version 20.10+)
- [Docker Compose](https://docs.docker.com/compose/) (version 2.0+ or legacy 1.29+)
- Make (for using the Makefile commands)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/BrahimJandri/Inception.git
cd Inception
```

2. The project will automatically create required data directories during setup.

### Configuration

1. Review and modify the environment variables in `srcs/.env` to match your setup:
```bash
# Domain configuration
DOMAIN_NAME=bjandri.42.fr

# Database credentials
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=wordpress_db
MYSQL_USER=your_db_user
MYSQL_PASSWORD=your_db_password

# WordPress admin credentials
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=your_admin_password
WP_ADMIN_EMAIL=admin@yourdomain.com
```

2. Update the data paths to match your system:
```bash
MYSQL_DATA_PATH=/home/yourusername/data/mariadb
WP_DATA_PATH=/home/yourusername/data/wordpress
PR_DATA_PATH=/home/yourusername/data/portainer
```

### Usage

Start the entire infrastructure with a single command:
```bash
make all
```

This will:
1. Create necessary data directories
2. Build all Docker images
3. Start all services in the background

---

## Services

### Core Services

| Service | Description | Port | Access |
|---------|-------------|------|--------|
| **NGINX** | Web server with SSL/TLS | 80, 443 | https://bjandri.42.fr |
| **WordPress** | Content management system | - | Via NGINX |
| **MariaDB** | Database server | - | Internal network only |

### Bonus Services

| Service | Description | Port | Access |
|---------|-------------|------|--------|
| **Redis** | Caching server | - | Internal network only |
| **FTP** | File transfer server | 21, 21000-21010 | ftp://bjandri.42.fr |
| **Adminer** | Database management | - | https://bjandri.42.fr/adminer/ |
| **Static Site** | Portfolio website | - | https://bjandri.42.fr/portfolio/ |
| **Portainer** | Container management | 9443 | http://localhost:9443 |

---

## Project Structure

```
Inception/
├── Makefile                    # Main automation commands
├── README.md                   # This file
├── License                     # MIT License
├── inception.png              # Project logo
└── srcs/                      # Source directory
    ├── .env                   # Environment variables
    ├── docker-compose.yml     # Service orchestration
    └── requirements/          # Service configurations
        ├── nginx/             # NGINX web server
        │   ├── Dockerfile
        │   └── conf/          # NGINX configuration
        ├── wordpress/         # WordPress CMS
        │   ├── Dockerfile
        │   └── conf/          # WordPress configuration
        ├── mariadb/           # MariaDB database
        │   ├── Dockerfile
        │   └── conf/          # Database configuration
        └── bonus/             # Additional services
            ├── redis/         # Redis cache
            ├── ftp/           # FTP server
            ├── adminer/       # Database admin
            ├── static-site/   # Portfolio site
            └── portainer/     # Container management
```

---

## Makefile Commands

The project includes a comprehensive Makefile for easy management:

| Command | Description |
|---------|-------------|
| `make all` | Build and start all services (default) |
| `make setup` | Create required data directories |
| `make build` | Build all Docker images |
| `make up` | Start all services |
| `make down` | Stop all services |
| `make restart` | Restart all services |
| `make logs` | View service logs |
| `make status` | Show service status |
| `make clean` | Stop services and remove containers/images |
| `make fclean` | Full cleanup including data volumes |
| `make re` | Rebuild everything from scratch |
| `make test` | Display service URLs for testing |

### Examples

```bash
# Start the infrastructure
make all

# View logs of all services
make logs

# Check service status
make status

# Stop everything
make down

# Full reset and rebuild
make re
```

---

## Accessing Services

Once the infrastructure is running, you can access the services at:

### Web Services
- **WordPress Site**: https://bjandri.42.fr
- **Adminer (Database Admin)**: https://bjandri.42.fr/adminer/
- **Portfolio Site**: https://bjandri.42.fr/portfolio/
- **Portainer (Container Management)**: http://localhost:9443

### Credentials

**WordPress Admin:**
- Username: `bjandri`
- Password: `bjandri42`

**Database (via Adminer):**
- Server: `mariadb`
- Username: `bjandridb`
- Password: `bjandri42`
- Database: `wordpress_db`

**FTP Access:**
- Host: `bjandri.42.fr`
- Username: `ftpuser`
- Password: `ftppassword123`
- Port: 21

> **Note**: Change default credentials in the `.env` file for production use.
---

## Troubleshooting

### Common Issues

**1. Permission Denied on Data Directories**
```bash
sudo chown -R $USER:$USER /home/yourusername/data/
```

**2. Port Already in Use**
```bash
# Check what's using the port
sudo lsof -i :443
sudo lsof -i :80

# Stop conflicting services
sudo systemctl stop apache2
sudo systemctl stop nginx
```

**3. Docker Compose Command Not Found**
If using newer Docker versions, use:
```bash
docker compose up -d
```
Instead of:
```bash
docker-compose up -d
```

**4. SSL Certificate Issues**
The project generates self-signed certificates. For production, replace with valid certificates:
```bash
# Place your certificates in the nginx configuration
cp your-cert.crt srcs/requirements/nginx/conf/
cp your-private.key srcs/requirements/nginx/conf/
```

**5. Domain Resolution Issues**
Add the domain to your `/etc/hosts` file:
```bash
echo "127.0.0.1 bjandri.42.fr" | sudo tee -a /etc/hosts
```

### Logs and Debugging

View logs for specific services:
```bash
# All services
make logs

# Specific service
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Check service health:
```bash
docker ps
make status
```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Docker best practices
- Use multi-stage builds where appropriate
- Document any new services or configurations
- Test all changes thoroughly
- Update this README for any new features

---

## License

This project is licensed under the MIT License - see the [License](License) file for details.

---

## Acknowledgments

- Built as part of the 42 School curriculum
- Inspired by modern DevOps practices
- Thanks to the Docker and open-source community

---

**Made with ❤️ by [Brahim Jandri](https://github.com/BrahimJandri)**
