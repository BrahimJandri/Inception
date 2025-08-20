# Makefile
# Variables
COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env

# Default target
all: build up

# Create data directories
setup:
	@echo "Setting up data directories..."
	@mkdir -p $(shell grep MYSQL_DATA_PATH $(ENV_FILE) | cut -d'=' -f2)
	@mkdir -p $(shell grep WP_DATA_PATH $(ENV_FILE) | cut -d'=' -f2)
	@mkdir -p $(shell grep PR_DATA_PATH $(ENV_FILE) | cut -d'=' -f2) 

# Build all images (including bonus)
build: setup
	@echo "Building Docker images..."
	docker-compose -f $(COMPOSE_FILE) build

# Start all services (including bonus)
up: build
	@echo "Starting services..."
	docker-compose -f $(COMPOSE_FILE) up -d

# Start only mandatory services
up-mandatory: build
	@echo "Starting mandatory services only..."
	docker-compose -f $(COMPOSE_FILE) up -d mariadb wordpress nginx

# Start bonus services
up-bonus:
	@echo "Starting bonus services..."
	docker-compose -f $(COMPOSE_FILE) up -d redis ftp adminer static-site portainer

# Stop all services
down:
	@echo "Stopping services..."
	docker-compose -f $(COMPOSE_FILE) down

# Restart all services
restart: down up

# View logs
logs:
	docker-compose -f $(COMPOSE_FILE) logs -f

# View logs for specific service
logs-service:
	@echo "Usage: make logs-service SERVICE=<service_name>"
	@echo "Available services: mariadb, wordpress, nginx, redis, ftp, adminer, static-site, portainer"
	docker-compose -f $(COMPOSE_FILE) logs -f $(SERVICE)

# Clean everything
clean: down
	@echo "Cleaning up..."
	docker-compose -f $(COMPOSE_FILE) down -v --rmi all
	docker system prune -af

# Remove volumes and data
fclean: clean
	@echo "Removing volumes and data..."
	rm -rf $(shell grep MYSQL_DATA_PATH $(ENV_FILE) | cut -d'=' -f2)
	rm -rf $(shell grep WP_DATA_PATH $(ENV_FILE) | cut -d'=' -f2)
	rm -rf $(shell grep PR_DATA_PATH $(ENV_FILE) | cut -d'=' -f2) 

# Recreate everything
re: fclean all

# Show status
status:
	docker-compose -f $(COMPOSE_FILE) ps

# Enter containers
exec-mariadb:
	docker exec -it mariadb /bin/bash

exec-wordpress:
	docker exec -it wordpress /bin/bash

exec-nginx:
	docker exec -it nginx /bin/bash

exec-redis:
	docker exec -it redis /bin/bash

exec-ftp:
	docker exec -it ftp /bin/bash

exec-adminer:
	docker exec -it adminer /bin/bash

exec-static:
	docker exec -it static-site /bin/bash

exec-portainer:
	docker exec -it portainer /bin/sh

# Test services
test:
	@echo "Testing services..."
	@echo "WordPress: https://bjandri.42.fr"
	@echo "Adminer: https://bjandri.42.fr/adminer/"
	@echo "Portfolio: https://bjandri.42.fr/portfolio/"
	@echo "Portainer: https://bjandri.42.fr/portainer/ or https://bjandri.42.fr:9443"
	@echo "FTP: ftp://bjandri.42.fr:21"

.PHONY: all setup build up up-mandatory up-bonus down restart logs logs-service clean fclean re status test exec-mariadb exec-wordpress exec-nginx exec-redis exec-ftp exec-adminer exec-static exec-portainer