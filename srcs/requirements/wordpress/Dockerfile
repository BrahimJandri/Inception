# srcs/requirements/wordpress/Dockerfile
FROM debian:bullseye
RUN apt-get update && apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-zip \
    curl \
    && rm -rf /var/lib/apt/lists/*
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/wordpress_setup.sh /usr/local/bin/wordpress_setup.sh
RUN chmod +x /usr/local/bin/wordpress_setup.sh && \
    mkdir -p /run/php
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/wordpress_setup.sh"]
CMD ["php-fpm7.4", "-F"]