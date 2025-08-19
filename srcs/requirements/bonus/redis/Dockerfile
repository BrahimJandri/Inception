# srcs/requirements/bonus/redis/Dockerfile
FROM debian:bullseye

# Install Redis
RUN apt-get update && apt-get install -y \
    redis-server \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY conf/redis.conf /etc/redis/redis.conf
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create Redis user and directories
RUN mkdir -p /var/lib/redis /var/log/redis /var/run/redis \
    && chown -R redis:redis /var/lib/redis /var/log/redis /var/run/redis

# Expose Redis port
EXPOSE 6379

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["redis-server", "/etc/redis/redis.conf"]