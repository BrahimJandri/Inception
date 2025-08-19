FROM debian:bullseye

# Install curl and certificates
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Portainer
RUN curl -L https://github.com/portainer/portainer/releases/download/2.11.1/portainer-2.11.1-linux-amd64.tar.gz \
    -o portainer.tar.gz \
    && tar -xzf portainer.tar.gz \
    && rm portainer.tar.gz

# Expose Portainer UI port
EXPOSE 9000

# Copy entrypoint script
COPY tools/docker-entrypoint.sh /exe.sh
RUN chmod +x /exe.sh

# Run Portainer
CMD ["/exe.sh"]
