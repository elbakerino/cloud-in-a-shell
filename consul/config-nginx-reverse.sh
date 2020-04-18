#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

touch /etc/nginx/conf.d/consului.conf
cat >/etc/nginx/conf.d/consului.conf <<EOF
server {
    listen 8585;
    # server_name example.org;

    location / {
      #auth_basic           "Consul UI";
      #auth_basic_user_file /root/.credentials;
      proxy_pass           http://127.0.0.1:8500/;
    }
}
EOF

systemctl restart nginx

if $(hash ufw 2>/dev/null); then
  echo " > using ufw"
  ufw allow proto tcp port 8585
  ufw allow 80
  ufw allow 443

  ufw --force enable
fi

if $(hash firewall-cmd 2>/dev/null); then
  echo " > using firewalld"
  firewall-cmd --zone=public --add-port=8585/tcp --permanent
  firewall-cmd --zone=public --add-port=http/tcp --permanent
  firewall-cmd --zone=public --add-port=https/tcp --permanent

  firewall-cmd --reload
fi

OWN_PUB_IP=$(ip route get 8.8.8.8 | awk '{print $7}')
echo " ✓ Consul-UI Reverse Proxy: ${OWN_PUB_IP}:8585"
