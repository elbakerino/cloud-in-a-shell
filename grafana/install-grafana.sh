#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

# Grafana
V_GRAFANA=6.5.2
wget https://dl.grafana.com/oss/release/grafana_${V_GRAFANA}_amd64.deb
apt install -y adduser libfontconfig
dpkg -i grafana_${V_GRAFANA}_amd64.deb

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server

echo " ✓ Grafana"
