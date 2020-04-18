#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh

function printState() {
  if [[ ${1} = true ]]; then
    echo " ✓ ${2}"
  else
    echo " X ${2}"
  fi
}

echo ""
echo "Current State:"
printState ${INSTALLED_UBUNTU_BASICS} "Ubuntu Basics"

printState ${INSTALLED_APACHE} "Apache"
printState ${INSTALLED_NGINX} "NGINX"
printState ${INSTALLED_PHP} "PHP"
printState ${INSTALLED_HAPROXY} "HAProxy"
printState ${INSTALLED_MARIADB} "MariaDB"
printState ${INSTALLED_PROMETHEUS} "Prometheus + Grafana Master"
echo ""
printState ${INSTALLED_PROMETHEUS_EXPORTER_NODE} "Prometheus Exporter Node"
printState ${INSTALLED_PROMETHEUS_EXPORTER_APACHE} "Prometheus Exporter Apache"
printState ${INSTALLED_PROMETHEUS_EXPORTER_HAPROXY} "Prometheus Exporter HAProxy"
printState ${INSTALLED_PROMETHEUS_EXPORTER_MYSQL} "Prometheus Exporter MySQL"
printState ${INSTALLED_PROMETHEUS_EXPORTER_STATSD} "Prometheus Exporter StatsD"
echo ""
printState ${INSTALLED_ANSIBLE} "Ansible Master"
printState ${INSTALLED_ANSIBLE_NODE} "Ansible Node"
echo ""
printState ${INSTALLED_CONSUL} "Consul Master"
printState ${INSTALLED_CONSUL_NODE} "Consul Node"
echo ""
printState ${SETUP_SSH_AGENT} "SSH-Agent"
printState ${SETUP_CERTBOT_NGINX} "certbot NGINX"
printState ${SETUP_CERTBOT_APACHE} "certbot Apache"
printState ${SETUP_CERTBOT_HAPROXY} "certbot HAProxy"
printState ${SETUP_GIT_FINGERPRINTS} "Git Fingerprints"
printState ${SETUP_SERVER_PAGE} "Server Page"
