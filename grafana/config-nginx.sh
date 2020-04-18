#!/bin/bash

if test -z "${1}"; then
  echo "Missing server_name: ./config-nginx.sh <server-name>"
fi

NGING_HOST=${1}

cat >/etc/nginx/conf.d/grafana.conf <<EOF
server {
    listen 80;
    server_name ${NGING_HOST};

    location / {
      proxy_pass           http://localhost:3000/;
    }
}
EOF

systemctl reload nginx
