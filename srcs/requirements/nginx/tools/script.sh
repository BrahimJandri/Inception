#!/bin/sh

mkdir -p /etc/ssl/private /etc/ssl/certs

openssl req -newkey rsa:2048 -x509 -sha256 -days 7 -nodes \
	-keyout /etc/ssl/private/ssl.key \
	-out /etc/ssl/certs/ssl.crt \
	-subj "/C=MA/ST=BenGuerir/L=BG/O=42/OU=1337BG/CN=bjandri.42.fr"

# Copy the nginx configuration file to the correct location
cp /etc/nginx/conf/nginx.conf /etc/nginx/nginx.conf

# Test the configuration
nginx -t

exec "$@"