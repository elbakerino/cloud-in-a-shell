#!/bin/bash

# firewall config for monitoring access within private network

if test -z "${1}"; then
  echo "#! Missing argument network"
  exit 1
fi

# prometheus node-exporter
if $(hash ufw 2>/dev/null); then
  echo " > using ufw"
  ufw allow from ${1}/24 to any port 9102

  ufw --force enable
elif $(hash firewall-cmd 2>/dev/null); then
  echo " > using firewalld"

  NET=${1}
  function fwPort() {
    firewall-cmd --permanent \
      --add-rich-rule='rule family="ipv4" source address="'${NET}'/24" port port="'${1}'" protocol="'${2}'" accept'
  }
  fwPort 9102 'tcp'

  firewall-cmd --reload
else
  echo " #! Firewall not configured, only ufw and firewalld are supported."
  exit 1
fi

# get own ip in trusted subnet
OWN_PRIV_IP=$(ip route get ${1} | awk '{print $7}')
echo " ✓ Prometheus HAProxy Statsd"
echo "!> now add targets at monit master"
echo "   1. switch to master 2. add new targets, 9102 = statsd_exporter"
echo "   ./prometheus-add-target.sh ${OWN_PRIV_IP}:9102"
