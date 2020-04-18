#!/bin/bash

function printStateSelected() {
  if [[ ${1} = true ]]; then
    if [[ ${3} = true ]]; then
      if [[ ${REDO} = true ]]; then
        echo " ✓✓ ${2}, marked as task, done again"
      else
        echo " ✓● ${2}, marked as task, not done again"
        #echo "  marked as task, not done again"
      fi
    else
      echo " ✓  ${2}"
    fi
  else
    if [[ ${3} = true ]]; then
      echo " X✓ ${2}, marked as task"
      #echo "   ✓ marked as task"
    else
      echo " X  ${2}"
    fi
  fi
}

echo ""
printStateSelected ${INSTALLED_UBUNTU_BASICS} "Ubuntu Basics" ${USE_UBUNTU_BASICS}

printStateSelected ${INSTALLED_APACHE} "Apache" ${TO_INSTALL_APACHE}
printStateSelected ${INSTALLED_NGINX} "NGINX" ${TO_INSTALL_NGINX}
printStateSelected ${INSTALLED_PHP} "PHP" ${TO_INSTALL_PHP}
printStateSelected ${INSTALLED_HAPROXY} "HAProxy" ${TO_INSTALL_HAPROXY}
printStateSelected ${INSTALLED_MARIADB} "MariaDB" ${TO_INSTALL_MARIADB}
printStateSelected ${INSTALLED_PROMETHEUS} "Prometheus + Grafana Master" ${TO_INSTALL_PROMETHEUS}
echo ""
printStateSelected ${INSTALLED_PROMETHEUS_EXPORTER_NODE} "Prometheus Exporter Node" ${TO_INSTALL_PROMETHEUS_EXPORTER_NODE}
printStateSelected ${INSTALLED_PROMETHEUS_EXPORTER_APACHE} "Prometheus Exporter Apache" ${TO_INSTALL_PROMETHEUS_EXPORTER_APACHE}
printStateSelected ${INSTALLED_PROMETHEUS_EXPORTER_HAPROXY} "Prometheus Exporter HAProxy" ${TO_INSTALL_PROMETHEUS_EXPORTER_HAPROXY}
printStateSelected ${INSTALLED_PROMETHEUS_EXPORTER_MYSQL} "Prometheus Exporter MySQL" ${TO_INSTALL_PROMETHEUS_EXPORTER_MYSQL}
printStateSelected ${INSTALLED_PROMETHEUS_EXPORTER_STATSD} "Prometheus Exporter StatsD" ${TO_INSTALL_PROMETHEUS_EXPORTER_STATSD}
echo ""
printStateSelected ${INSTALLED_ANSIBLE} "Ansible Master" ${TO_INSTALL_ANSIBLE}
printStateSelected ${INSTALLED_ANSIBLE_NODE} "Ansible Node" ${TO_INSTALL_ANSIBLE_NODE}
echo ""
printStateSelected ${INSTALLED_CONSUL} "Consul Master" ${TO_INSTALL_CONSUL}
printStateSelected ${INSTALLED_CONSUL_NODE} "Consul Node" ${TO_INSTALL_CONSUL_NODE}
echo ""
printStateSelected ${SETUP_SSH_AGENT} "SSH-Agent" ${TO_SETUP_SSH_AGENT}
printStateSelected ${SETUP_CERTBOT_NGINX} "certbot NGINX" ${TO_SETUP_CERTBOT_NGINX}
printStateSelected ${SETUP_CERTBOT_APACHE} "certbot Apache" ${TO_SETUP_CERTBOT_APACHE}
printStateSelected ${SETUP_CERTBOT_HAPROXY} "certbot HAProxy" ${SETUP_CERTBOT_HAPROXY}
printStateSelected ${SETUP_GIT_FINGERPRINTS} "Git Fingerprints" ${TO_SETUP_GIT_FINGERPRINTS}
printStateSelected ${SETUP_SERVER_PAGE} "Server Page" ${TO_SETUP_SERVER_PAGE}
