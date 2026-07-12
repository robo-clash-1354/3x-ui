#!/bin/bash
set -e

echo "🚀 Starting Sanaei Panel + nginx reverse proxy..."

# پورت را از Railway بگیر یا از 3000 استفاده کن
export NGINX_PORT=${PORT:-3000}

cd /usr/local/x-ui

echo "🔧 Starting Sanaei Panel in background..."
# اجرای پنل روی 0.0.0.0 تا از بیرون در دسترس باشد
./x-ui setting -port 3000 -webBasePath /managepanel/ -username admin -password admin -listenIP 0.0.0.0 &
X_UI_PID=$!

echo "⏳ Waiting for panel to start on port 3000..."
# صبر می‌کنیم تا پنل واقعاً روی پورت 3000 شروع به کار کند
timeout 30 sh -c 'until nc -z 127.0.0.1 3000; do sleep 1; done' || echo "⚠️ Panel did not start within 30 seconds"

echo "🔧 Building nginx.conf for port: $NGINX_PORT"
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "▶️ Starting nginx in foreground on port $NGINX_PORT..."
nginx -t
exec nginx -g "daemon off;"
