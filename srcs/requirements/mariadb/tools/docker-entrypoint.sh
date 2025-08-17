#!/bin/bash
set -e

# Function to check if MySQL is running
mysql_is_running() {
    mysqladmin ping --silent
}

# Function to wait for MySQL to start
wait_for_mysql() {
    echo "Waiting for MySQL to start..."
    while ! mysql_is_running; do
        sleep 1
    done
    echo "MySQL is running!"
}

# Initialize MySQL data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MySQL data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start MySQL in background for configuration
echo "Starting MySQL temporarily for configuration..."
mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
MYSQL_PID=$!

# Wait for MySQL to be ready
wait_for_mysql

# Configure MySQL
echo "Configuring MySQL..."

# Set root password
mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASSWORD}');"

# Create database
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"

# Create user and grant privileges
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

# Grant root access from any host (for development - in production, restrict this)
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;"

# Flush privileges
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

echo "MySQL configuration completed!"

# Stop the temporary MySQL instance
kill $MYSQL_PID
wait $MYSQL_PID

# Start MySQL normally
echo "Starting MySQL server..."
exec mysqld --user=mysql --datadir=/var/lib/mysql