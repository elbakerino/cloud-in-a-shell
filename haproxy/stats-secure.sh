#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

if test -z "${1}"
then
  echo "#! Missing argument username: ./tool/haproxy-stats-secure.sh <username>"
  exit
fi

UNAME=${1}
conffile=/etc/haproxy/haproxy.cfg

echo "Securing HAProxy Stats with Basic-Auth..."

echo "Username: ${UNAME}"

read -sp "Enter the password: " pass

if test -z "${pass}"
then
  echo "#! Pass is empty"
  exit
fi

sed -i "s/stats auth.*/stats auth ${UNAME}:${pass}/" ${conffile}

if grep -q "stats auth ${UNAME}:${pass}" "${conffile}"; then
  echo " ✓ Changed HAProxy Stat Auth"
  echo " > Manual reload needed: systemctl reload haproxy"
else
  echo " X Failed to changed HAProxy Stat Auth"
  echo "   Check if 'stats auth' exists in config: vi ${conffile}"
fi
