#!/bin/bash
set -e

echo "Setting up Adminer..."

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
until nc -z mariadb 3306; do
    echo "MariaDB is not ready yet, waiting..."
    sleep 2
done
echo "MariaDB is ready!"

# Ensure Adminer is properly downloaded
if [ ! -f /var/www/html/index.php ]; then
    echo "Downloading Adminer..."
    curl -L https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
        -o /var/www/html/index.php
fi

# Create a custom theme/styling (optional)
cat > /var/www/html/adminer.css << 'EOF'
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    margin: 0;
    padding: 20px;
}

#content {
    background: rgba(255,255,255,0.95);
    border-radius: 10px;
    padding: 20px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.2);
    backdrop-filter: blur(10px);
}

h1 {
    color: #667eea;
    text-align: center;
    margin-bottom: 30px;
}
EOF

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Adminer setup completed!"
echo "Access Adminer at: https://bjandri.42.fr/adminer/"
echo "Database credentials:"
echo "  Server: mariadb"
echo "  Username: wp_user"
echo "  Password: wp_password123"
echo "  Database: wordpress_db"

echo "Starting PHP-FPM..."
exec "$@"