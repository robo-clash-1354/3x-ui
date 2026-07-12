#!/bin/bash
set -e

echo "🚀 Starting Sanaei Panel + nginx reverse proxy..."

export NGINX_PORT=3000
export PANEL_PORT=2053

cd /usr/local/x-ui

echo "🔧 Configuring Sanaei Panel on port $PANEL_PORT..."
./x-ui setting -port $PANEL_PORT -webBasePath /managepanel/ -username admin -password admin -listenIP 0.0.0.0

echo "🔧 Starting Sanaei Panel as daemon..."
./x-ui start

echo "⏳ Waiting 10 seconds for panel to start..."
sleep 10

# تست اتصال به پنل
echo "📡 Testing panel connection on port $PANEL_PORT..."
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:$PANEL_PORT/managepanel/ | grep -q "200\|302"; then
    echo "✅ Panel is reachable!"
else
    echo "❌ Panel is NOT reachable!"
    echo "📋 Checking panel status..."
    ./x-ui status
fi

echo "🔧 Building nginx.conf for port: $NGINX_PORT"
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "▶️ Starting nginx in foreground on port $NGINX_PORT..."
nginx -t
exec nginx -g "daemon off;"
