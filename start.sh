#!/bin/bash
set -e

echo "🚀 Starting Sanaei Panel + nginx reverse proxy..."

export NGINX_PORT=3000
export PANEL_PORT=2053

cd /usr/local/x-ui

echo "🔧 Configuring Sanaei Panel on port $PANEL_PORT..."
./x-ui setting -port $PANEL_PORT -webBasePath /managepanel/ -username admin -password admin -listenIP 0.0.0.0

# ===== فعال‌سازی IP Limit از طریق دیتابیس =====
echo "🔧 Enabling IP Limit feature..."
sqlite3 /etc/x-ui/x-ui.db "UPDATE settings SET value='true' WHERE key='enableIpLimit';" 2>/dev/null || echo "⚠️ IP Limit already enabled or table not found"

echo "🔧 Starting Sanaei Panel..."
./x-ui &

echo "⏳ Waiting 15 seconds..."
sleep 15

echo "📡 Testing connection..."
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:$PANEL_PORT/managepanel/

echo "🔧 Building nginx.conf..."
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "▶️ Starting nginx..."
nginx -t
exec nginx -g "daemon off;"
