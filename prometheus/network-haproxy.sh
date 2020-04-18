#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

# firewall config for monitoring access within private network

network=${1}
if test -z "${network}"; then
  network="${NET_MONIT}"
fi

gateway=${2}
if test -z "${gateway}"; then
  gateway="${GW_MONIT}"
fi

if $(hash ufw 2>/dev/null);then
  echo " > using ufw"
  # prometheus haproxy-exporter
  ufw allow from ${network}/24 to any port 9101
fi

if $(hash firewall-cmd 2>/dev/null); then
  echo " > using firewalld"
  firewall-cmd --permanent \
    --add-rich-rule='rule family="ipv4" source address="'${network}'/24" port port="9101" protocol="tcp" accept'
  firewall-cmd --reload
fi

OWN_PRIV_IP=$(ip route get ${gateway} | awk '{print $7}')
echo " ✓ Prometheus HAProxy Network"
echo "!> now add targets at monit master"
echo "   1. switch to master 2. add new targets, 9101 = haproxy exporter"
echo "   ./prometheus-add-target.sh ${OWN_PRIV_IP}:9101"
