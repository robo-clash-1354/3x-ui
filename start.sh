#!/bin/bash
set -e

echo "🚀 Starting Sanaei Panel + nginx reverse proxy..."

# Nginx روی پورت 3000 گوش می‌دهد (پورت ورودی Railway)
export NGINX_PORT=3000

# پورت داخلی پنل سنایی (متفاوت از NGINX_PORT)
export PANEL_PORT=2053

cd /usr/local/x-ui

echo "🔧 Starting Sanaei Panel on internal port $PANEL_PORT..."
./x-ui setting -port $PANEL_PORT -webBasePath /managepanel/ -username admin -password admin -listenIP 127.0.0.1 &
X_UI_PID=$!

echo "⏳ Waiting 10 seconds for panel to start..."
sleep 10

echo "🔧 Building nginx.conf for port: $NGINX_PORT"
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "▶️ Starting nginx in foreground on port $NGINX_PORT..."
nginx -t
exec nginx -g "daemon off;"
