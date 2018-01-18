#!/usr/bin/env bash
set -euo pipefail

cat << CONFIG > /etc/nginx/conf.d/default.conf
server {
      listen 80;
      server_name localhost;

      return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name localhost;

    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DHE+AES128:!ADH:!AECDH:!MD5;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

    ssl_session_cache shared:SSL:60m;
    ssl_session_timeout 12m;

    location / {
        proxy_http_version 1.1;
        proxy_pass ${PROXY_PASS};

        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_set_header X-Forwarded-Port 443;
        proxy_set_header Host \$host;

        fastcgi_param HTTPS on;
    }
}
CONFIG

exec "$@"
