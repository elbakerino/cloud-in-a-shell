#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

VHOST_NAME=${1}
VHOST_DOCROOT=/var/www/vhosts/${1}
conffile=/etc/apache2/sites-available/${VHOST_NAME}.conf
conffile_le=/etc/apache2/sites-available/${VHOST_NAME}-le-ssl.conf

if test -z "${2}"
then
    VHOST_DOCROOT=${VHOST_DOCROOT}
else
    VHOST_DOCROOT=${VHOST_DOCROOT}/${2}
fi

mkdir -p ${VHOST_DOCROOT}
chown www-data:www-data -R ${VHOST_DOCROOT}

echo "vhost '${VHOST_NAME}' changing document root '${VHOST_DOCROOT}'"
echo ""

sed -i "s~DocumentRoot.*~DocumentRoot ${VHOST_DOCROOT}~" ${conffile}
sed -i "s~<Directory.*~<Directory \"${VHOST_DOCROOT}\">~" ${conffile}
echo " ✓ updated ${VHOST_NAME}.conf"

if test -f "${conffile_le}"; then
  sed -i "s~DocumentRoot.*~DocumentRoot ${VHOST_DOCROOT}~" ${conffile_le}
  sed -i "s~<Directory.*~<Directory \"${VHOST_DOCROOT}\">~" ${conffile_le}
  echo " ✓ updated ${VHOST_NAME}-le-ssl.conf"
fi

systemctl reload apache2

echo ""
echo " ✓ $(cat /etc/apache2/sites-available/${VHOST_NAME}.conf | grep -o "DocumentRoot.*")"

echo "Check file with:      cat ${conffile}"
if test -f "${conffile_le}"; then
  echo "Check SSL file with:  cat ${conffile_le}"
fi
