FROM debian:bullseye

# Install Nginx and OpenSSL
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Create SSL certificate directory
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed SSL certificate with correct domain
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42/CN=bjandri.42.fr"

# Copy configuration files
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf /etc/nginx/sites-available/default
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Remove default site and create symlink
RUN rm -f /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

# Create necessary directories
RUN mkdir -p /var/log/nginx /var/lib/nginx /run/nginx

# Expose HTTPS port
EXPOSE 443

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]