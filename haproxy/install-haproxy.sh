#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

dnf install haproxy -y

mkdir -p /etc/haproxy
if ! test -f "/etc/haproxy/haproxy.state"; then
  touch /etc/haproxy/haproxy.state
  cat >/etc/haproxy/haproxy.state <<EOF

EOF
else
  echo "   Skipping haproxy.state creation, exists."
fi

source ${DIR_CUR}/config-haproxy.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

echo "   Created /etc/haproxy/haproxy.cfg"

mkdir -p /etc/haproxy/certs

# adding haproxy static file loader, certbot-haproxy.sh uses this for the webroot extension
# thanks to: https://discourse.haproxy.org/t/how-do-i-serve-a-single-static-file-from-haproxy/32/11
mkdir -p /var/lib/haproxy/docroot
touch /etc/haproxy/static-server.lua
cat ${DIR_CUR}/haproxy-static-server.lua >/etc/haproxy/static-server.lua
echo "   Created /etc/haproxy/static-server.lua"


if ! test -f "/var/log/haproxy"; then
  touch /var/log/haproxy
fi

if ! test -f "/var/log/haproxy-access_log"; then
  touch /var/log/haproxy-access_log
fi

if ! test -f "/etc/rsyslog.d/haproxy.conf"; then
  touch /etc/rsyslog.d/haproxy.conf
fi

cat >/etc/rsyslog.d/haproxy.conf <<EOF
$ModLoad          :omusrmsg:imudp
$UDPServerAddress :omusrmsg:127.0.0.1
$UDPServerRun     :omusrmsg:514

local2.*          /var/log/haproxy
local3.*          /var/log/haproxy-access_log
EOF

systemctl restart rsyslog
echo "   Syslog to /var/log/haproxy* is configured"

if systemctl is-active --quiet haproxy; then
  systemctl restart haproxy
else
  systemctl start haproxy
fi

systemctl enable haproxy

echo " ✓ Installed + Enabled HAProxy"
INSTALLED_HAPROXY=true
sed -i "s/INSTALLED_HAPROXY=false/INSTALLED_HAPROXY=true/" ${DIR_CUR}/../../state_init.sh
