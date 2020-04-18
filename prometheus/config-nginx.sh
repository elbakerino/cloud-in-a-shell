#!/bin/bash

if test -z "${1}"; then
  echo "Missing server_name: ./config-nginx.sh <server-name>"
fi

NGING_HOST=${1}

cat >/etc/nginx/conf.d/prometheus.conf <<EOF
server {
    listen 80;
    server_name ${NGING_HOST};

    location / {
      auth_basic           "Prometheus";
      auth_basic_user_file /etc/prometheus/.credentials;
      proxy_pass           http://localhost:9090/;
    }
}
EOF

systemctl reload nginx
