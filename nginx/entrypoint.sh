#!/usr/bin/env bash
set -euo pipefail

cat << CONFIG > /etc/nginx/conf.d/default.conf
server {
    listen 443 ssl;

    server_name localhost;
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    location / {
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

nginx -g "daemon off;"
