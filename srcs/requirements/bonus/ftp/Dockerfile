FROM debian:bullseye

# Install vsftpd and dependencies
RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

# Create FTP user first
RUN useradd -m -s /bin/bash ftpuser \
    && echo "ftpuser:ftppassword123" | chpasswd

# Point FTP user to WordPress volume
RUN usermod -d /var/www/html ftpuser \
    && mkdir -p /var/www/html/uploads \
    && chown -R ftpuser:ftpuser /var/www/html \
    && chmod -R 755 /var/www/html

# Create necessary directories
RUN mkdir -p /var/run/vsftpd/empty \
    && mkdir -p /var/log \
    && touch /var/log/vsftpd.log

# Copy configuration
COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set proper ownership
RUN chown root:root /etc/vsftpd.conf \
    && chmod 644 /etc/vsftpd.conf

# Expose FTP ports
EXPOSE 21 21000-21010

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
