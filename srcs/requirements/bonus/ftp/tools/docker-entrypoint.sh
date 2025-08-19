#!/bin/bash
set -e

echo "Setting up FTP server..."

# Create ftpuser in userlist
echo "ftpuser" > /etc/vsftpd.userlist

# Create log files with proper permissions
touch /var/log/vsftpd.log
chown root:root /var/log/vsftpd.log

# Ensure the secure chroot directory exists
mkdir -p /var/run/vsftpd/empty

# Wait for WordPress volume to be ready
echo "Waiting for WordPress files to be available..."
while [ ! -d /var/www/html ]; do
    echo "WordPress directory not ready, waiting..."
    sleep 2
done

# Set up FTP user home directory
echo "Setting up FTP user permissions..."
usermod -d /var/www/html ftpuser 2>/dev/null || true
chown -R ftpuser:ftpuser /var/www/html
chmod -R 755 /var/www/html

echo "FTP server setup completed!"
echo "FTP credentials:"
echo "  Server: localhost or bjandri.42.fr"
echo "  Port: 21"
echo "  Username: ftpuser" 
echo "  Password: ftppassword123"
echo "  Passive ports: 21000-21010"

echo "Starting FTP server in foreground mode..."
# Run vsftpd in foreground mode to prevent container exit
exec vsftpd /etc/vsftpd.conf