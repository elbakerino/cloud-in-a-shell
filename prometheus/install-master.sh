#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

useradd --no-create-home --shell /usr/sbin/nologin prometheus
useradd --no-create-home --shell /bin/false node_exporter

mkdir /etc/prometheus
mkdir /var/lib/prometheus

chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

V_PROMETHEUS=2.2.1
wget https://github.com/prometheus/prometheus/releases/download/v${V_PROMETHEUS}/prometheus-${V_PROMETHEUS}.linux-amd64.tar.gz
tar xfz prometheus-${V_PROMETHEUS}.linux-amd64.tar.gz
cd prometheus-${V_PROMETHEUS}.linux-amd64

cp ./prometheus /usr/local/bin/
cp ./promtool /usr/local/bin/

chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

cp -r ./consoles /etc/prometheus
cp -r ./console_libraries /etc/prometheus

mkdir -p /data/prometheus
chown -R prometheus:prometheus /data/prometheus
chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries

cd .. && rm -rf prometheus-*

cat >/etc/prometheus/prometheus.yml <<EOF
global:
  scrape_interval:     15s
  evaluation_interval: 15s

rule_files:
  # - "first.rules"
  # - "second.rules"

scrape_configs:
  - job_name: prometheus
    scrape_interval: 5s
    static_configs:
    - targets:
      - localhost:9090
      - localhost:9100
EOF
# note on array syntax, in .yml no ['localhost:9090'] syntax can be used, not supported by `yq` https://mikefarah.github.io/yq/

chown prometheus:prometheus /etc/prometheus/prometheus.yml

# now you can start manually and visit <ip>:9090
# -u prometheus /usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus/ --web.console.templates=/etc/prometheus/consoles --web.console.libraries=/etc/prometheus/console_libraries

# todo: dynamic folder for prometheus storage
cat >/etc/systemd/system/prometheus.service <<EOF
[Unit]
  Description=Prometheus Monitoring
  Wants=network-online.target
  After=network-online.target

[Service]
  User=prometheus
  Group=prometheus
  Type=simple
  ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path="/data/prometheus" \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-admin-api \
  --web.external-url=https://localhost:443
  ExecReload=/bin/kill -HUP $MAINPID

[Install]
  WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

apt install -yq nginx apache2-utils

echo " ✓ Prometheus Master"
INSTALLED_PROMETHEUS=true
sed -i "s/INSTALLED_PROMETHEUS=false/INSTALLED_PROMETHEUS=true/" ${DIR_CUR}/../../state_init.sh
