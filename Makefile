all: up
up:
	@mkdir -p /home/$(USER)/data/wordpress
	@mkdir -p /home/$(USER)/data/mariadb
	@docker-compose -f srcs/docker-compose.yml up -d --build
down:
	@docker-compose -f srcs/docker-compose.yml down
stop:
	@docker-compose -f srcs/docker-compose.yml stop
start:
	@docker-compose -f srcs/docker-compose.yml start
clean: down
	@docker system prune -af
	@docker volume prune -f
fclean: clean
	@sudo rm -rf /home/$(USER)/data
re: fclean all
.PHONY: all up down stop start clean fclean re