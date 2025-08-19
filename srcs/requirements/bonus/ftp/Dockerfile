# srcs/requirements/bonus/ftp/Dockerfile
FROM debian:bullseye

# Install vsftpd
RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

# Copy configuration
COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create FTP user
RUN useradd -m -s /bin/bash ftpuser \
    && echo "ftpuser:ftppassword123" | chpasswd

# Create necessary directories
RUN mkdir -p /var/run/vsftpd/empty

# Expose FTP ports
EXPOSE 21 21000-21010

# Set the entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["vsftpd", "/etc/vsftpd.conf"]