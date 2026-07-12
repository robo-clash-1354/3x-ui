#!/bin/bash
set -e

echo "🚀 Starting Sanaei Panel + nginx reverse proxy..."

export NGINX_PORT=3000
export PANEL_PORT=2053

# ===== راه‌اندازی Fail2ban =====
echo "🛡️ Starting Fail2ban service..."
mkdir -p /var/run/fail2ban
fail2ban-server -x start || echo "⚠️ Fail2ban already running or failed to start"

cd /usr/local/x-ui

echo "🔧 Configuring Sanaei Panel on port $PANEL_PORT..."
./x-ui setting -port $PANEL_PORT -webBasePath /managepanel/ -username admin -password admin -listenIP 0.0.0.0

echo "🔧 Connecting Fail2ban to panel..."
./x-ui setup-fail2ban || echo "⚠️ Fail2ban setup failed"

echo "🔧 Starting Sanaei Panel directly in background..."
nohup ./x-ui run &

echo "⏳ Waiting 15 seconds for panel to fully start..."
sleep 15

echo "📡 Testing panel connection on port $PANEL_PORT..."
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:$PANEL_PORT/managepanel/

echo "🔧 Building nginx.conf for port: $NGINX_PORT"
envsubst '${NGINX_PORT}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

echo "▶️ Starting nginx in foreground on port $NGINX_PORT..."
nginx -t
exec nginx -g "daemon off;"
