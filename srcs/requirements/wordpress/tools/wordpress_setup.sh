#!/bin/bash
cd /var/www/html
if [ ! -f wp-config.php ]; then
    # Download WordPress CLI
    curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.5.0/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp

    # Download WordPress
    wp core download --allow-root

    # Configure WordPress
    wp config create --allow-root \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=$DB_HOST:3306

    # Install WordPress
    wp core install --allow-root \
        --url=$DOMAIN_NAME \
        --title="Inception WordPress Site" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL

    # Create additional user
    wp user create --allow-root \
        $WP_USER $WP_USER_EMAIL \
        --role=author \
        --user_pass=$WP_USER_PASSWORD

    chown -R www-data:www-data /var/www/html
fi

exec "$@"