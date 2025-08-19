#!/bin/bash
set -e

echo "Starting Redis server..."

# Create necessary directories
mkdir -p /var/lib/redis /var/log/redis /var/run/redis
chown -R redis:redis /var/lib/redis /var/log/redis /var/run/redis

# Start Redis
exec "$@"