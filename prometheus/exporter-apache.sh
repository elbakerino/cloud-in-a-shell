#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

echo "Installing Prometheus Apache Exporter"

useradd -rs /bin/false apache_exporter

V_APACHE_EXPORTER=0.7.0
wget https://github.com/Lusitaniae/apache_exporter/releases/download/v${V_APACHE_EXPORTER}/apache_exporter-${V_APACHE_EXPORTER}.linux-amd64.tar.gz
tar xvf apache_exporter-${V_APACHE_EXPORTER}.linux-amd64.tar.gz
cp apache_exporter-${V_APACHE_EXPORTER}.linux-amd64/apache_exporter /usr/local/bin
chown apache_exporter:apache_exporter /usr/local/bin/apache_exporter
rm -rf apache_exporter-${V_APACHE_EXPORTER}.linux-amd64.tar.gz apache_exporter-${V_APACHE_EXPORTER}.linux-amd64

cat >/etc/systemd/system/apache_exporter.service <<EOF
[Unit]
Description=Apache Exporter

[Service]
User=apache_exporter
ExecStart=/usr/local/bin/apache_exporter \
  --scrape_uri='http://localhost/server-status/?auto'

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start apache_exporter
systemctl enable apache_exporter

echo "   allow port 9117 for prometheus master"

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
echo " ✓ Prometheus Apache Exporter"
INSTALLED_PROMETHEUS_EXPORTER_APACHE=true
sed -i "s/INSTALLED_PROMETHEUS_EXPORTER_APACHE=false/INSTALLED_PROMETHEUS_EXPORTER_APACHE=true/" ${DIR_CUR}/../../state_init.sh
