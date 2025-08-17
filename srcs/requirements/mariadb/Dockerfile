FROM debian:bullseye

# Install MariaDB server
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration files
COPY conf/mariadb.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create necessary directories and set permissions
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld

# Expose MySQL port
EXPOSE 3306

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["mysqld"]