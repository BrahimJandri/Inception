#!/bin/bash
set -e

echo "Setting up static website..."

# Ensure required directories exist
mkdir -p /var/www/html /var/log/nginx /var/lib/nginx /run/nginx

# Set permissions for web files
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Create robots.txt if missing
if [ ! -f /var/www/html/robots.txt ]; then
cat > /var/www/html/robots.txt << 'EOF'
User-agent: *
Allow: /

Sitemap: https://bjandri.42.fr/portfolio/sitemap.xml
EOF
fi

# Create sitemap.xml if missing
if [ ! -f /var/www/html/sitemap.xml ]; then
cat > /var/www/html/sitemap.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://bjandri.42.fr/portfolio/</loc>
    <lastmod>2024-01-01</lastmod>
    <changefreq>monthly</changefreq>
    <priority>1.0</priority>
  </url>
</urlset>
EOF
fi

echo "Static website setup completed!"

# Validate Nginx configuration
echo "Testing Nginx configuration..."
nginx -t

echo "Starting Nginx..."
exec "$@"
