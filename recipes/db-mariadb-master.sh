#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

source ${DIR_CUR}/../tool/basics-ubuntu.sh

source ${DIR_CUR}/../mariadb/install-mariadb.sh

# Prometheus monitoring exporter
source ${DIR_CUR}/../prometheus/exporter-node.sh
source ${DIR_CUR}/../prometheus/network-node.sh

mysql_secure_installation

# configure MySQL monit, creates monitoring user (interactive)
./prometheus/exporter-mysql.sh
./prometheus/network-mysql.sh
