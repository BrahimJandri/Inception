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

# Build all images
build: setup
	@echo "Building Docker images..."
	docker-compose -f $(COMPOSE_FILE) build

# Start all services
up: build
	@echo "Starting services..."
	docker-compose -f $(COMPOSE_FILE) up -d

# Stop all services
down:
	@echo "Stopping services..."
	docker-compose -f $(COMPOSE_FILE) down

# Restart all services
restart: down up

# View logs
logs:
	docker-compose -f $(COMPOSE_FILE) logs -f

# Clean everything
clean: down
	@echo "Cleaning up..."
	docker-compose -f $(COMPOSE_FILE) down -v --rmi all
	docker system prune -af

# Remove volumes and data
fclean: clean
	@echo "Removing data directories..."
	sudo rm -rf $(shell grep MYSQL_DATA_PATH $(ENV_FILE) | cut -d'=' -f2)
	sudo rm -rf $(shell grep WP_DATA_PATH $(ENV_FILE) | cut -d'=' -f2)

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

.PHONY: all setup build up down restart logs clean fclean re status exec-mariadb exec-wordpress exec-nginx