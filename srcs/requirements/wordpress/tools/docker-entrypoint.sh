#!/bin/bash
set -e

# Wait for MariaDB
echo "Waiting for MariaDB..."
until nc -z mariadb 3306; do
    echo "MariaDB not ready, retrying..."
    sleep 2
done

# Wait for Redis
echo "Waiting for Redis..."
until nc -z redis 6379; do
    echo "Redis not ready, retrying..."
    sleep 2
done

cd /var/www/html

# If not installed, set up WordPress
if [ ! -f wp-config.php ]; then
    echo "Installing WordPress..."
    wp core download --allow-root

    wp config create \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

    wp config set WP_REDIS_HOST 'redis' --allow-root
    wp config set WP_REDIS_PORT 6379 --allow-root
    wp config set WP_REDIS_PASSWORD "${REDIS_PASSWORD:-redispassword123}" --allow-root
    wp config set WP_REDIS_DATABASE 0 --allow-root
    wp config set WP_CACHE true --allow-root

    sleep 5  # Give DB final time to settle

    wp core install \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root

    wp user create \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root

    wp rewrite structure '/%postname%/' --allow-root
    wp rewrite flush --allow-root

    echo "WordPress setup completed!"
else
    echo "WordPress already configured, skipping setup..."
fi

exec "$@"
