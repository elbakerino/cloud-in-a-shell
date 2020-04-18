#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

echo "Installing Prometheus HAProxy Exporter"

if [[ ${INSTALLED_PROMETHEUS_EXPORTER_HAPROXY} != true ]]; then
  useradd -rs /bin/false haproxy_exporter

  V_HAPROXY_EXPORTER=0.10.0
  wget https://github.com/prometheus/haproxy_exporter/releases/download/v${V_HAPROXY_EXPORTER}/haproxy_exporter-${V_HAPROXY_EXPORTER}.linux-amd64.tar.gz
  tar xvf haproxy_exporter-${V_HAPROXY_EXPORTER}.linux-amd64.tar.gz
  cp haproxy_exporter-${V_HAPROXY_EXPORTER}.linux-amd64/haproxy_exporter /usr/local/bin
  chown haproxy_exporter:haproxy_exporter /usr/local/bin/haproxy_exporter
  rm -rf haproxy_exporter-${V_HAPROXY_EXPORTER}.linux-amd64.tar.gz haproxy_exporter-${V_HAPROXY_EXPORTER}.linux-amd64
  if ! test -f "/usr/local/bin/haproxy_exporter"; then
    echo " X Download or installation failed"
    exit
  fi
fi

cat >/etc/systemd/system/haproxy_exporter.service <<EOF
[Unit]
Description=HAProxy Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=haproxy_exporter
Group=haproxy_exporter
Type=simple
ExecStart=/usr/local/bin/haproxy_exporter \
  --haproxy.scrape-uri=unix:/var/run/haproxy-exporter.sock
[Install]
WantedBy=multi-user.target
EOF

touch /var/run/haproxy-exporter.sock
chown haproxy_exporter:haproxy_exporter /var/run/haproxy-exporter.sock

systemctl daemon-reload
systemctl start haproxy_exporter
systemctl enable haproxy_exporter

echo " > allow port 9101 for prometheus master"

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
echo " ✓ Prometheus HAProxy Exporter"
INSTALLED_PROMETHEUS_EXPORTER_HAPROXY=true
sed -i "s/INSTALLED_PROMETHEUS_EXPORTER_HAPROXY=false/INSTALLED_PROMETHEUS_EXPORTER_HAPROXY=true/" ${DIR_CUR}/../../state_init.sh
