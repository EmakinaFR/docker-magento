FROM nginx:latest

MAINTAINER Alexandre Jardin <info@ajardin.fr>
LABEL maintainer="Alexandre Jardin <info@ajardin.fr>"

# Install HTTPS requirements
RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Generate self-signed SSL certificate
RUN \
    mkdir -p /etc/ssl/private/ /etc/ssl/certs/ && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt \
        -subj "/CN=example.com"

# Install custom entrypoint
COPY ./entrypoint.sh /usr/local/bin/docker-custom-entrypoint
RUN chmod 777 /usr/local/bin/docker-custom-entrypoint
ENTRYPOINT ["docker-custom-entrypoint"]
