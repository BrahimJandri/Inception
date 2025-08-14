# Variables
DOCKER_COMPOSE_CMD := docker compose
DATA_DIR := /home/$(USER)/data
WORDPRESS_DIR := $(DATA_DIR)/wordpress
MARIADB_DIR := $(DATA_DIR)/mariadb
COMPOSE_FILE := srcs/docker-compose.yml

# Hide command output by default
.SILENT:

# Default target
all: up

# Create data directories and start containers
up:
	@mkdir -p $(WORDPRESS_DIR) $(MARIADB_DIR)
	@$(DOCKER_COMPOSE_CMD) -f $(COMPOSE_FILE) up -d --build

# Stop containers
down:
	@$(DOCKER_COMPOSE_CMD) -f $(COMPOSE_FILE) down

# Stop containers without removing
stop:
	@$(DOCKER_COMPOSE_CMD) -f $(COMPOSE_FILE) stop

# Start stopped containers
start:
	@$(DOCKER_COMPOSE_CMD) -f $(COMPOSE_FILE) start

# Show container logs
logs:
	@$(DOCKER_COMPOSE_CMD) -f $(COMPOSE_FILE) logs -f --tail=50

# Show status of containers
status:
	@$(DOCKER_COMPOSE_CMD) -f $(COMPOSE_FILE) ps

# Clean Docker resources
clean: down
	@$(DOCKER_COMPOSE_CMD) -f $(COMPOSE_FILE) rm -f
	@docker system prune -af
	@docker volume prune -f

# Remove data directories
fclean: clean
	@sudo rm -rf $(DATA_DIR)

# Rebuild everything from scratch
re: fclean all

# Declare phony targets
.PHONY: all up down stop start logs status clean fclean re
