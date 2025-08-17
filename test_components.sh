#!/bin/bash

echo "=== Testing Inception Project ==="

# Check if .env file exists and is configured
if [ ! -f "srcs/.env" ]; then
    echo "❌ .env file not found!"
    exit 1
fi

echo "✅ .env file found"

# Build and start services
echo "Building and starting services..."
make up

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 30

# Test MariaDB
echo "=== Testing MariaDB ==="
if docker exec mariadb mysql -u root -p$(grep MYSQL_ROOT_PASSWORD srcs/.env | cut -d'=' -f2) -e "SHOW DATABASES;" > /dev/null 2>&1; then
    echo "✅ MariaDB is running and accessible"
else
    echo "❌ MariaDB test failed"
fi

# Test WordPress
echo "=== Testing WordPress ==="
if docker exec wordpress wp --allow-root core version > /dev/null 2>&1; then
    echo "✅ WordPress is installed and accessible"
else
    echo "❌ WordPress test failed"
fi

# Test Nginx
echo "=== Testing Nginx ==="
if curl -k -s https://localhost:443 | grep -q "WordPress\|wp-content" > /dev/null 2>&1; then
    echo "✅ Nginx is serving WordPress content"
else
    echo "❌ Nginx test failed"
fi

# Show container status
echo "=== Container Status ==="
docker-compose -f srcs/docker-compose.yml ps

echo "=== Testing Complete ==="
echo "Access your site at: https://$(grep DOMAIN_NAME srcs/.env | cut -d'=' -f2)"