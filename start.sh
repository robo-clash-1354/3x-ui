#!/bin/bash
set -e

echo "🚀 Starting Sanaei Panel + nginx reverse proxy..."

export NGINX_PORT=3000
export PANEL_PORT=2053

cd /usr/local/x-ui

echo "🔧 Configuring Sanaei Panel on port $PANEL_PORT..."
./x-ui setting -port $PANEL_PORT -webBasePath /managepanel/ -username admin -password admin -listenIP 0.0.0.0

echo "🔧 Starting Sanaei Panel..."
./x-ui &

echo "⏳ Waiting 15 seconds..."
sleep 15

echo "📡 Testing connection..."
curl -v http://127.0.0.1:$PANEL_PORT/managepanel/

echo "🔧 Building nginx.conf..."
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "▶️ Starting nginx..."
nginx -t
exec nginx -g "daemon off;"
