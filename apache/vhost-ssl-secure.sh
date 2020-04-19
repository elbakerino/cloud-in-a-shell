#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

VHOST_NAME=${1}
if test -z "${1}"; then
  echo "#! Missing argument vhosts name: ./tool/vhost-ssl-secure.sh <name> [<email>]"
  echo "   List current vhosts with: ./tool/vhost-list.sh"
  exit
fi

echo "Securing vhost '${VHOST_NAME}'"

conffile=/etc/apache2/sites-available/${VHOST_NAME}.conf
conffile_le=/etc/apache2/sites-available/${VHOST_NAME}-le-ssl.conf

if test -f "${conffile_le}"; then
  echo " ✓ SSL vhost by Let's Encrypt exists"
else
  echo " X SSL vhost"
fi

if grep -q "RewriteRule ^ https://%" "${conffile}"; then
  echo " ✓ Redir to SSL exists"
else
  echo " X Redir to SSL"
fi

SERV_NAMES=""
if grep -q "ServerName" "${conffile}"; then
  SERV_NAME=$(cat ${conffile} | grep -o "ServerName.*" | cut -f2- -d" ")
  echo " > ServerName:   ${SERV_NAME}"
  SERV_NAMES="${SERV_NAMES} -d ${SERV_NAME}"
fi

if grep -q "ServerAlias" "${conffile}"; then
  echo " > ServerAliase:"
  while read SERV_NAME; do
    SERV_NAMES="${SERV_NAMES} -d ${SERV_NAME}"
    echo "                 ${SERV_NAME}"
  done <<<$(cat ${conffile} | grep -o "ServerAlias.*" | cut -f2- -d" ")
fi

if test -z "${2}"; then
  echo "   Creating/updating cert '${VHOST_NAME}'..."
  echo ""
  if  [[ ${3} == 1 ]]; then
    echo "   Forcing renew..."
    certbot run --apache --cert-name ${VHOST_NAME} -n ${SERV_NAMES} --redirect --agree-tos --force-renewal
  else
    certbot run --apache --cert-name ${VHOST_NAME} -n ${SERV_NAMES} --redirect --agree-tos
  fi
else
  echo "   Creating/updating cert '${VHOST_NAME}' with warning email '${2}'..."
  if  [[ ${3} == 1 ]]; then
    echo "   Forcing renew..."
    certbot run --apache --cert-name ${VHOST_NAME} -n ${SERV_NAMES} --redirect --agree-tos --force-renewal -m ${2}
  else
    certbot run --apache --cert-name ${VHOST_NAME} -n ${SERV_NAMES} --redirect --agree-tos -m ${2}
  fi
fi

echo ""
echo " ✓ cert updated"
systemctl restart apache2
echo " ✓ apache restarted"
