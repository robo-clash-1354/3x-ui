FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    bash \
    ca-certificates \
    sqlite3 \
    nginx \
    gettext-base \
    tzdata \
    && ln -sf /usr/share/zoneinfo/Asia/Tehran /etc/localtime \
    && rm -rf /var/lib/apt/lists/*

ENV ARCH=amd64

RUN echo "Getting latest version of Sanaei Panel..." && \
    tag_version=$(curl -Ls --retry 5 --retry-delay 3 --connect-timeout 15 --max-time 60 "https://api.github.com/repos/MHSanaei/3x-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    echo "Latest version: ${tag_version}" && \
    curl -fLR --retry 5 --retry-delay 3 --connect-timeout 15 --max-time 300 -o /tmp/x-ui-linux-${ARCH}.tar.gz "https://github.com/MHSanaei/3x-ui/releases/download/${tag_version}/x-ui-linux-${ARCH}.tar.gz" && \
    tar -xzf /tmp/x-ui-linux-${ARCH}.tar.gz -C /usr/local/ && \
    rm /tmp/x-ui-linux-${ARCH}.tar.gz && \
    chmod +x /usr/local/x-ui/x-ui

RUN mkdir -p /etc/x-ui /var/log/x-ui

# کپی فایل‌ها با بررسی وجود
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY start.sh /start.sh
RUN chmod +x /start.sh && ls -la /start.sh  # ← این خط برای دیباگ اضافه شده

RUN mkdir -p /usr/share/nginx/html/view
COPY sub-view.html /usr/share/nginx/html/view/index.html

EXPOSE 3000

CMD ["/start.sh"]
