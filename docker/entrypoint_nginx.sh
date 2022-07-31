#!/bin/bash
set -e

# configure nginx
cp /workdir/nginx-params-snippet.conf /etc/nginx/snippets/ssl-params.conf
envsubst '$SSL_CERT_FILE,$SSL_KEY_FILE' < /workdir/nginx-signed-snippet.conf > /etc/nginx/snippets/nginx.conf
envsubst '$URL,$IP_ADDR' < /workdir/nginx-ssl-signed.conf > /etc/nginx/sites-available/default

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"

# --- end of file --- #
