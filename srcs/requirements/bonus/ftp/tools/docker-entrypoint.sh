#!/bin/bash
set -e

echo "Setting up FTP server..."

# Create ftpuser in userlist
echo "ftpuser" > /etc/vsftpd.userlist

# Create log files
touch /var/log/vsftpd.log
chown root:root /var/log/vsftpd.log

# Set WordPress directory as FTP home
usermod -d /var/www/html ftpuser
chown -R ftpuser:ftpuser /var/www/html

echo "Starting FTP server..."
exec "$@"