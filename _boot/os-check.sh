#!/bin/bash

OS=false
if test -f "/etc/lsb-release" && grep -q "Ubuntu 18" "/etc/lsb-release"; then
  echo " > on Ubuntu 18.x"
  OS="Ubuntu"
elif test -f "/etc/lsb-release" && grep -q "Ubuntu 20" "/etc/lsb-release"; then
  echo " > on Ubuntu 18.x"
  OS="Ubuntu"
elif test -f "/etc/centos-release" && grep -qE "CentOS .+ release 8" "/etc/centos-release"; then
  echo " > on CentOS 8"
  OS="CentOS"
else
  if test -f "/etc/lsb-release"; then
    echo " #! unknown/unsupported OS, currently only CentOS 8 and Ubuntu 18.x are supported, found: $(grep -o "DISTRIB_DESCRIPTION.*" "/etc/lsb-release" | cut -f2 -d"=")"
  elif test -f "/etc/centos-release"; then
    echo " #! unknown/unsupported OS, currently only CentOS 8 and Ubuntu 18.x are supported, found: $(cat "/etc/centos-release")"
  else
    echo " #! unknown/unsupported OS, currently only CentOS 8 and Ubuntu 18.x are supported"
  fi

  exit
fi

if test -f "/etc/lsb-release" && grep -q "Ubuntu 20" "/etc/lsb-release"; then
  echo " > !ALPHA! on Ubuntu 20.x"
fi

function getOwnIP() {
  OWN_PRIV_IP_TMP=$(ip route get ${1})
  if [[ $(echo ${OWN_PRIV_IP_TMP} | awk '{print $7}') =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo ${OWN_PRIV_IP_TMP}| awk '{print $7}'
  elif [[ $(echo ${OWN_PRIV_IP_TMP} | awk '{print $5}') =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo ${OWN_PRIV_IP_TMP}| awk '{print $5}'
  else
    echo " X Can't determine own ip"
    exit 1
  fi
}
