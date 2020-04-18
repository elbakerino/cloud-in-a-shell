#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

VHOST_NAME=${1}
conffile=/etc/apache2/sites-available/${VHOST_NAME}.conf
conffile_le=/etc/apache2/sites-available/${VHOST_NAME}-le-ssl.conf

echo "disabling vhost '${VHOST_NAME}'"
echo ""

a2dissite ${VHOST_NAME}.conf
echo " ✓ disabled ${VHOST_NAME}.conf"

if test -f "${conffile_le}"; then
  a2dissite ${VHOST_NAME}-le-ssl.conf
  echo " ✓ disabled ${VHOST_NAME}-le-ssl.conf"
fi

systemctl reload apache2
