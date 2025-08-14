FROM alpine:3.20

RUN apk update && apk add --no-cache \
    php83 \
    php83-fpm \
    php83-mysqli \
    php83-xml \
    php83-mbstring \
    php83-phar \
    php83-opcache \
    php83-json \
    php83-session \
    wget \
    unzip \
    netcat-openbsd

RUN mkdir -p /var/www/html

COPY tools/script.sh /script.sh

RUN chmod +x /script.sh

EXPOSE 9000

ENTRYPOINT ["/script.sh"]