#!/bin/bash
set -e

echo "Setting up FTP server..."

# Read FTP credentials from env (fall back if missing)
FTP_USER=${FTP_USER:-ftpuser}
FTP_PASSWORD=${FTP_PASSWORD:-$(openssl rand -base64 12)}

# Create ftpuser if not exists
if ! id "$FTP_USER" &>/dev/null; then
    useradd -m -s /bin/bash "$FTP_USER"
fi

# Set password
echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

# Add to vsftpd userlist
echo "$FTP_USER" > /etc/vsftpd.userlist

# Create log file
touch /var/log/vsftpd.log
chown root:root /var/log/vsftpd.log

# Ensure chroot directory exists
mkdir -p /var/run/vsftpd/empty

# Wait for WordPress volume
echo "Waiting for WordPress files to be available..."
while [ ! -d /var/www/html ]; do
    echo "WordPress directory not ready, waiting..."
    sleep 2
done

# Set permissions
echo "Setting up FTP user permissions..."
usermod -d /var/www/html "$FTP_USER" || true
chown -R "$FTP_USER:$FTP_USER" /var/www/html
chmod -R 755 /var/www/html

echo "FTP server setup completed!"
echo "Starting FTP server in foreground mode..."
exec vsftpd /etc/vsftpd.conf
