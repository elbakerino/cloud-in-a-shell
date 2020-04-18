#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

if test -z "${1}"; then
  echo "#! Missing argument backend name: ./tool/haproxy-server-dis.sh <backend> <server>"
  exit
fi

if test -z "${2}"; then
  echo "#! Missing argument server name: ./tool/haproxy-server-dis.sh <backend> <server>"
  exit
fi

SERV_BACKEND=${1}
SERV_NAME=${2}
conffile=/etc/haproxy/haproxy.cfg

echo " Disabling server '${SERV_NAME}' on backend '${SERV_BACKEND}'"

backed_info=$(awk "/^backend ${SERV_BACKEND}/,/#----/" ${conffile})

if test -z "${backed_info}"; then
  echo " #! backend not found"
  exit
fi

DYN_SERV_INFO=$(echo "show servers state ${SERV_BACKEND}" | socat stdio /var/run/haproxy.sock | grep -e "${SERV_NAME} ")

if test -z "${DYN_SERV_INFO}"; then
  echo " #! server not found"
  exit
fi

srv_name=$(echo "${DYN_SERV_INFO}" | cut -f4 -d" ") # srv_name
srv_addr=$(echo "${DYN_SERV_INFO}" | cut -f5 -d" ") # srv_addr
srv_op_state=$(echo "${DYN_SERV_INFO}" | cut -f6 -d" ") # srv_op_state, 5 = init
srv_admin_state=$(echo "${DYN_SERV_INFO}" | cut -f7 -d" ") # srv_admin_state, 5 = init, 4=ready
srv_port=$(echo "${DYN_SERV_INFO}" | cut -f19 -d" ") # srv_port

printf " Current: ${srv_name} ${srv_addr}:${srv_port} "
if [ ${srv_admin_state} = 4 ]; then
  printf "ready"
elif [ ${srv_admin_state} = 5 ]; then
  printf "maint"
elif [ ${srv_admin_state} = 12 ]; then
  printf "drain"
fi
printf "\n"

echo " Changing state ..."

TMP=$(echo "set server ${SERV_BACKEND}/${SERV_NAME} state drain" | socat stdio /var/run/haproxy.sock)
echo "show servers state" | socat stdio /var/run/haproxy.sock > /etc/haproxy/haproxy.state

DYN_SERV_INFO=$(echo "show servers state ${SERV_BACKEND}" | socat stdio /var/run/haproxy.sock | grep -e "${SERV_NAME} ")
srv_admin_state=$(echo "${DYN_SERV_INFO}" | cut -f7 -d" ") # srv_admin_state, 5 = init, 4=ready

if [ ${srv_admin_state} = 4 ]; then
  echo " X Server ${SERV_BACKEND}/${SERV_NAME} is ready"
elif [ ${srv_admin_state} = 5 ]; then
  echo " X Server ${SERV_BACKEND}/${SERV_NAME} is disabled"
elif [ ${srv_admin_state} = 12 ]; then
  echo " ✓ Server ${SERV_BACKEND}/${SERV_NAME} is drained"
fi
