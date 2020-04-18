#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

source ${DIR_CUR}/../tool/basics-ubuntu.sh

source ${DIR_CUR}/../prometheus/install-master.sh

source ${DIR_CUR}/../grafana/install-grafana.sh

# Prometheus monitoring exporter
source ${DIR_CUR}/../prometheus/exporter-node.sh

htpasswd -bc /etc/prometheus/.credentials admin admin

ufw allow 80
ufw allow 443
