FROM debian:bullseye

# Install Nginx and clean up apt cache in one step
RUN apt-get update && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*

# Copy website files and set ownership at the same time
COPY --chown=www-data:www-data tools/website/ /var/www/html/

# Copy Nginx config and entrypoint
COPY conf/nginx.conf /etc/nginx/sites-available/default
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Remove default site and enable our config
RUN rm -f /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Set entrypoint and default command
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
