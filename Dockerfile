FROM ghcr.io/szemeng76/lunatv:latest

RUN apk add --no-cache nginx

RUN mkdir -p /etc/nginx/http.d && cat > /etc/nginx/http.d/default.conf <<'EOF'
server {
    listen 8080;

    location = /health {
        default_type application/json;
        return 200 '{"status":"ok"}';
    }

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

RUN printf '#!/bin/sh\nnode server.js &\nnginx -g "daemon off;"\n' > /start.sh \
    && chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
