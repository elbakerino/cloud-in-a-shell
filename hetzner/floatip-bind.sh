#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

if test -z "${1}"; then
  echo "Missing IPv4: ./floatip-bind.sh <ip> [<ip6>]"
fi

FLOATING_IP=${1}

if ! test -z "${2}"; then
  FLOATING_IP6=${2}
fi

if [ ${OS} = "Ubuntu" ]; then
  mkdir -p /etc/network/interfaces.d/60-floating-ip.cfg
  cat >/etc/network/interfaces.d/60-floating-ip.cfg <<EOF
auto eth0:1
iface eth0:1 inet static
    address ${FLOATING_IP}
    netmask 32
EOF

  if ! test -z "${FLOATING_IP6}"; then
    echo "" >>/etc/network/interfaces.d/60-floating-ip.cfg
    echo "auto eth0:2" >>/etc/network/interfaces.d/60-floating-ip.cfg
    echo "    iface eth0:2 inet6 static" >>/etc/network/interfaces.d/60-floating-ip.cfg
    echo "    address ${FLOATING_IP6}" >>/etc/network/interfaces.d/60-floating-ip.cfg
    echo "    netmask 64" >>/etc/network/interfaces.d/60-floating-ip.cfg
  fi

  read -p " Restart Network? (y|N) " do_restart

  if [[ ${do_restart} == "y" ]] || [[ ${do_restart} == "Y" ]]; then
    service networking restart
    echo "Network restarted"
  fi

elif [ ${OS} = "CentOS" ]; then
  mkdir -p /etc/sysconfig/network-scripts
  cat >/etc/sysconfig/network-scripts/ifcfg-eth0:1 <<EOF
BOOTPROTO=static
DEVICE=eth0:1
IPADDR=${FLOATING_IP}
PREFIX=32
TYPE=Ethernet
USERCTL=no
ONBOOT=yes
EOF
  ifconfig eth0:1 ${FLOATING_IP} up

  if ! test -z "${FLOATING_IP6}"; then
    echo "IPV6ADDR=${FLOATING_IP6}" >>/etc/sysconfig/network-scripts/ifcfg-eth0:1
    echo "IPV6INIT=yes" >>/etc/sysconfig/network-scripts/ifcfg-eth0:1
    ifconfig eth0:1 inet6 add ${FLOATING_IP6}
  fi

#  not needed for RHEL8
#  read -p " Restart Network? (y|N) " do_restart
#
#  if [[ ${do_restart} == "y" ]] || [[ ${do_restart} == "Y" ]]; then
#    systemctl restart NetworkManager.service
#    echo "Network restarted"
#  fi

else
  echo "#! Unsupported OS"
  exit
fi
