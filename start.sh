#!/bin/bash
set -e

echo "🚀 Starting Sanaei Panel + nginx reverse proxy..."

export NGINX_PORT=3000
export PANEL_PORT=2053

# ===== راه‌اندازی Fail2ban (در صورت وجود) =====
echo "🛡️ Checking Fail2ban..."
if command -v fail2ban-server &> /dev/null; then
    mkdir -p /var/run/fail2ban
    fail2ban-server -x start 2>/dev/null || echo "⚠️ Fail2ban already running"
else
    echo "⚠️ Fail2ban not found, skipping..."
fi

cd /usr/local/x-ui

echo "🔧 Configuring Sanaei Panel on port $PANEL_PORT..."
./x-ui setting -port $PANEL_PORT -webBasePath /managepanel/ -username admin -password admin -listenIP 0.0.0.0

# ===== اتصال Fail2ban به پنل (در صورت وجود) =====
if command -v fail2ban-server &> /dev/null; then
    echo "🔧 Connecting Fail2ban to panel..."
    ./x-ui setup-fail2ban 2>/dev/null || echo "⚠️ Fail2ban setup skipped (already configured)"
fi

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
