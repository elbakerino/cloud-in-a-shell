#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

DO_REDO=false

POSITIONAL=()
while [ "$1" != "" ]; do
  PARAM=$(echo $1 | awk -F= '{print $1}')
  VALUE=$(echo $1 | awk -F= '{print $2}')
  DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
  case $PARAM in
  --redo)
    DO_REDO=true
    ;;
  *)
    POSITIONAL+=("$1") # save it in an array for later
    ;;
  esac
  shift
done
set -- "${POSITIONAL[@]}"

VHOST_NAME=${1}
VHOST_SERVERNAME=${2}
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

if [[ ${DO_REDO} = false ]] && grep -q "${VHOST_SERVERNAME}" ${conffile}; then
  echo " ✓ Server ${VHOST_SERVERNAME} already exists"
  exit
fi

echo "   site '${VHOST_NAME}' adding server '${VHOST_SERVERNAME}'"
echo ""

sed -i "s/.*server_name .*/    server_name $(echo ${VHOST_SERVERNAME});/" ${conffile}
echo " ✓ updated ${VHOST_NAME}.conf"

if test -f "${conffile_le}"; then
  sed -i "s/.*server_name .*/    server_name $(echo ${VHOST_SERVERNAME});/" ${conffile_le}
  echo " ✓ updated ${VHOST_NAME}.confE"
fi

systemctl reload nginx

echo ""
echo "Current Names:"
cat ${conffile} | grep -o "server_name.*"
echo ""

echo "Check file with:      cat ${conffile}"
if test -f "${conffile_le}"; then
  echo "Check SSL file with:  cat ${conffile_le}"
fi
echo ""
