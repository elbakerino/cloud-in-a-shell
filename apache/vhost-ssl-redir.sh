#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

VHOST_NAME=${1}
conffile=/etc/apache2/sites-available/${VHOST_NAME}.conf

if grep -q "RewriteRule ^ https://%" "${conffile}"; then
  echo " ✓ Redir to SSL already exists"
  exit
fi

sed -i "s~</VirtualHost.*~\n    RewriteEngine on \n    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]\n</VirtualHost>~" ${conffile}

echo "vhost: ${VHOST_NAME}"

systemctl reload apache2

echo " ✓ Updated ${VHOST_NAME}.conf"
cat ${conffile}
echo ""
