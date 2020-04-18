#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

function log() {
  echo "$(date +"%Y-%m-%d %T.%N") ${1}"
}

log "Installing Prometheus Node Exporter"

useradd -rs /bin/false node_exporter

V_NODE_EXPORTER=0.18.1
wget https://github.com/prometheus/node_exporter/releases/download/v${V_NODE_EXPORTER}/node_exporter-${V_NODE_EXPORTER}.linux-amd64.tar.gz
tar xvf node_exporter-${V_NODE_EXPORTER}.linux-amd64.tar.gz
cp node_exporter-${V_NODE_EXPORTER}.linux-amd64/node_exporter /usr/local/bin
chown node_exporter:node_exporter /usr/local/bin/node_exporter
rm -rf node_exporter-${V_NODE_EXPORTER}.linux-amd64.tar.gz node_exporter-${V_NODE_EXPORTER}.linux-amd64

cat >/etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=node_exporter
Group=node_exporter
ExecStart=/usr/local/bin/node_exporter \
    --collector.mountstats \
    --collector.logind \
    --collector.processes \
    --collector.ntp \
    --collector.systemd \
    --collector.tcpstat \
    --collector.wifi

Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start node_exporter
systemctl enable node_exporter

log "allow port 9100 for prometheus master"

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
echo " ✓ Prometheus Node Exporter"
INSTALLED_PROMETHEUS_EXPORTER_NODE=true
sed -i "s/INSTALLED_PROMETHEUS_EXPORTER_NODE=false/INSTALLED_PROMETHEUS_EXPORTER_NODE=true/" ${DIR_CUR}/../../state_init.sh
