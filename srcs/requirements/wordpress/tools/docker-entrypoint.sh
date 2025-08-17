#!/bin/bash
set -e

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
until nc -z mariadb 3306; do
    echo "MariaDB is not ready yet, waiting..."
    sleep 2
done
echo "MariaDB is ready!"

# Change to WordPress directory
cd /var/www/html

# Download WordPress if not already present
if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
    
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root
    
    # Wait a bit more for database to be fully ready
    sleep 5
    
    echo "Installing WordPress..."
    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
    
    echo "Creating additional user..."
    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root
    
    # Set permalink structure for better URLs
    wp rewrite structure '/%postname%/' --allow-root
    wp rewrite flush --allow-root
    
    echo "WordPress installation completed!"
else
    echo "WordPress already installed, skipping setup..."
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Starting PHP-FPM..."
exec "$@"