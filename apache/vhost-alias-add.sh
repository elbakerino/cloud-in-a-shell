#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

VHOST_NAME=${1}
VHOST_SERVERNAME=${2}
conffile=/etc/apache2/sites-available/${VHOST_NAME}.conf
conffile_le=/etc/apache2/sites-available/${VHOST_NAME}-le-ssl.conf

if grep -q "ServerAlias ${VHOST_SERVERNAME}" ${conffile}; then
  echo " ✓ Alias ${VHOST_SERVERNAME} already exists"
  exit
fi

echo "vhost '${VHOST_NAME}' adding alias '${VHOST_SERVERNAME}'"
echo ""

sed -i "0,/ServerName.\+/s//\0\n    ServerAlias ${VHOST_SERVERNAME}/" ${conffile}
echo " ✓ updated ${VHOST_NAME}.conf"

if test -f "${conffile_le}"; then
  sed -i "0,/ServerName.\+/s//\0\n    ServerAlias ${VHOST_SERVERNAME}/" ${conffile_le}
  echo " ✓ updated ${VHOST_NAME}-le-ssl.conf"
fi

systemctl reload apache2

echo ""
echo "Current Names:"
cat /etc/apache2/sites-available/${VHOST_NAME}.conf | grep -o "ServerName.*"
cat /etc/apache2/sites-available/${VHOST_NAME}.conf | grep -o "ServerAlias.*"
echo ""

echo "Check file with:      cat ${conffile}"
if test -f "${conffile_le}"; then
  echo "Check SSL file with:  cat ${conffile_le}"
fi
echo ""
