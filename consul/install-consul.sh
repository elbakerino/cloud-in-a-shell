#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

DO_REDO=false

while [ "$1" != "" ]; do
  PARAM=$(echo $1 | awk -F= '{print $1}')
  VALUE=$(echo $1 | awk -F= '{print $2}')
  DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
  case $PARAM in
  --redo)
    DO_REDO=true
    ;;
  *)
    # ignoring unkown
    printf ""
    ;;
  esac
  shift
done

if [[ ${INSTALLED_CONSUL} != true || ${DO_REDO} = true ]]; then
  #

  if [ ${OS} = "Ubuntu" ]; then
    apt install tar ufw wget curl zip unzip -yq
  elif [ ${OS} = "CentOS" ]; then
    dnf install tar firewalld wget curl zip unzip -y
    systemctl start firewalld
    systemctl enable firewalld
  fi

  if $(hash ufw 2>/dev/null); then
    echo " > using ufw"
    ufw allow proto tcp from ${NET_SERVICE_DISCOVERY}/24 to any port 8300,8301,8302,8400,8500,8600
    ufw allow proto udp from ${NET_SERVICE_DISCOVERY}/24 to any port 8301,8302,8600

    # web ui
    # ufw allow proto tcp port 8500

    ufw --force enable
  elif $(hash firewall-cmd 2>/dev/null); then
    echo " > using firewalld"

    function fwPort() {
      firewall-cmd --permanent \
        --add-rich-rule='rule family="ipv4" source address="'${NET_SERVICE_DISCOVERY}'/24" port port="'${1}'" protocol="'${2}'" accept'
    }
    fwPort 8300 'tcp'
    fwPort 8301 'tcp'
    fwPort 8302 'tcp'
    fwPort 8400 'tcp'
    fwPort 8500 'tcp'
    fwPort 8600 'tcp'

    fwPort 8301 'udp'
    fwPort 8302 'udp'
    fwPort 8600 'udp'

    # web ui
    # firewall-cmd --zone=public --add-port=8500/tcp --permanent

    firewall-cmd --reload
  else
    echo " #! Firewall not configured, only ufw and firewalld are supported."
  fi

  setenforce 0
  sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

  CONSUL_V="1.6.2"
  wget https://releases.hashicorp.com/consul/${CONSUL_V}/consul_${CONSUL_V}_linux_amd64.zip
  unzip "consul_${CONSUL_V}_linux_amd64.zip" -d consul_tmp

  rm -rf /usr/local/bin/consul

  mv consul_tmp/consul /usr/local/bin/consul
  consul_check=$(/usr/local/bin/consul -v)

  rm -rf consul_tmp "consul_${CONSUL_V}_linux_amd64.zip"

  if echo "${consul_check}" | grep -q "${CONSUL_V}"; then
    echo " ✓ Installed Consul"
  else
    echo " X Failed: Consul Installation"
    exit
  fi

  groupadd --system consul
  useradd -s /sbin/nologin --system -g consul consul
  mkdir -p /var/lib/consul /etc/consul.d
  chown -R consul:consul /var/lib/consul /etc/consul.d
  chmod -R 775 /var/lib/consul /etc/consul.d
fi

source ${DIR_CUR}/configure.sh "$@" --defaults

systemctl daemon-reload
systemctl start consul
systemctl enable consul

echo " ✓ Installed + Enabled Consul"
INSTALLED_CONSUL=true
updateState "INSTALLED_CONSUL"
