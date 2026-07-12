#!/bin/bash
set -e

echo "🚀 Starting Sanaei Panel + nginx reverse proxy..."

export NGINX_PORT=3000

cd /usr/local/x-ui

echo "🔧 Starting Sanaei Panel in background..."
./x-ui setting -port 3000 -webBasePath /managepanel/ -username admin -password admin &
X_UI_PID=$!

sleep 3

echo "🔧 Building nginx.conf for fixed port: $NGINX_PORT"
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "▶️ Starting nginx in foreground on port $NGINX_PORT..."
nginx -t
exec nginx -g "daemon off;"