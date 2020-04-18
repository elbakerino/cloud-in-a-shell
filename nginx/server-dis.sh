#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

VHOST_NAME=${1}
conffile=/etc/nginx/conf.d/${VHOST_NAME}.conf
conffile_le=/etc/nginx/conf.d/${VHOST_NAME}.confE

if ! grep -q "server_name" ${conffile}; then
  echo " X server_name var not in ${conffile}"
  exit 1
fi

if test -f "${conffile_le}"; then
  if ! grep -q "server_name" ${conffile}; then
    echo " X server_name var not in ${conffile}"
    exit 1
  fi
fi

echo "   site '${VHOST_NAME}' disabling server_name"
echo ""

sed -i "s/.*server_name /   # server_name /" ${conffile}
echo " ✓ updated ${VHOST_NAME}.conf"

if test -f "${conffile_le}"; then
  sed -i "s/.*server_name /   # server_name /" ${conffile_le}
  echo " ✓ updated ${VHOST_NAME}.confE"
fi

systemctl reload nginx

echo ""
echo "Current Line:"
cat ${conffile} | grep -o ".*server_name.*"
echo ""

echo "Check file with:      cat ${conffile}"
if test -f "${conffile_le}"; then
  echo "Check SSL file with:  cat ${conffile_le}"
fi
echo ""
