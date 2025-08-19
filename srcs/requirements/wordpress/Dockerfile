FROM debian:bullseye

# Install PHP-FPM 8.3 and required extensions including Redis
RUN apt-get update && apt-get install -y \
    lsb-release apt-transport-https ca-certificates wget gnupg \
    && wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
    && apt-get update && apt-get install -y \
    php8.3-fpm \
    php8.3-mysql \
    php8.3-curl \
    php8.3-gd \
    php8.3-intl \
    php8.3-mbstring \
    php8.3-soap \
    php8.3-xml \
    php8.3-xmlrpc \
    php8.3-zip \
    php8.3-redis \
    curl \
    wget \
    unzip \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Download and install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Copy configuration files
COPY conf/www.conf /etc/php/8.3/fpm/pool.d/www.conf
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create WordPress directory
RUN mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html

# Create PHP-FPM run directory
RUN mkdir -p /run/php \
    && chown www-data:www-data /run/php

# Expose PHP-FPM port
EXPOSE 9000

WORKDIR /var/www/html

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm8.3", "-F"]