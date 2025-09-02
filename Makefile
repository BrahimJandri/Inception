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
	@echo "Removing volumes and data..."
	rm -rf $(shell grep MYSQL_DATA_PATH $(ENV_FILE) | cut -d'=' -f2)
	rm -rf $(shell grep WP_DATA_PATH $(ENV_FILE) | cut -d'=' -f2)
	rm -rf $(shell grep PR_DATA_PATH $(ENV_FILE) | cut -d'=' -f2) 

# Recreate everything
re: fclean all

# Show status
status:
	docker-compose -f $(COMPOSE_FILE) ps

# Test services
test:
	@echo "Testing services..."
	@echo "WordPress: https://bjandri.42.fr"
	@echo "Adminer: https://bjandri.42.fr/adminer/"
	@echo "Portfolio: https://bjandri.42.fr/portfolio/"
	@echo "Portainer: http://localhost:9443"

.PHONY: all setup build up down restart logs clean fclean re status test