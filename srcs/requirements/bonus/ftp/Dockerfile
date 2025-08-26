FROM debian:bullseye

# Install vsftpd and dependencies
RUN apt-get update && apt-get install -y \
    vsftpd \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Prepare FTP directories
RUN mkdir -p /var/run/vsftpd/empty \
    && mkdir -p /var/log \
    && touch /var/log/vsftpd.log

# Copy configuration and entrypoint
COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY tools/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set proper ownership for config
RUN chown root:root /etc/vsftpd.conf \
    && chmod 644 /etc/vsftpd.conf

# Expose FTP ports
EXPOSE 21 21000-21010

# Entrypoint will create user + set password at runtime
ENTRYPOINT ["docker-entrypoint.sh"]
