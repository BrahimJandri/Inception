FROM debian:bullseye

# Install Nginx and clean up apt cache in one step
RUN apt-get update && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*

# Copy website files and set ownership at the same time
COPY --chown=www-data:www-data tools/ /var/www/html/

CMD ["nginx", "-g", "daemon off;"]
