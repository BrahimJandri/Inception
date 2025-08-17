#!/bin/bash
set -e

echo "Starting Nginx..."

# Test nginx configuration
nginx -t

# Start nginx
exec "$@"