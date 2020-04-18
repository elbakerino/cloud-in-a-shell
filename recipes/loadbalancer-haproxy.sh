#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

source ${DIR_CUR}/../tool/basics-centos.sh
source ${DIR_CUR}/../haproxy/install-haproxy.sh

echo " Configuring firewall for http, https and stats port"

firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --zone=public --add-service=https --permanent
firewall-cmd --zone=public --add-port=${STATS_PORT}/tcp --permanent
firewall-cmd --reload

# Prometheus monitoring exporter
source ${DIR_CUR}/../prometheus/exporter-haproxy.sh
source ${DIR_CUR}/../prometheus/exporter-node.sh

source ${DIR_CUR}/../prometheus/network-node.sh
source ${DIR_CUR}/../prometheus/network-haproxy.sh

# disable prometheus node exporters `ntp-collector`
sed -i "s/--collector.ntp//" /etc/systemd/system/node_exporter.service && \
    systemctl daemon-reload && systemctl restart node_exporter
