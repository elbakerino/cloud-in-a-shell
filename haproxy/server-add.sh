#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

if test -z "${1}"; then
  echo "#! Missing argument backend name: ./tool/haproxy-server-add.sh <backend> <server> <ip> <port>"
  exit
fi

if test -z "${2}"; then
  echo "#! Missing argument server name: ./tool/haproxy-server-add.sh <backend> <server> <ip> <port>"
  exit
fi

if test -z "${3}"; then
  echo "#! Missing argument <ip>: ./tool/haproxy-server-add.sh <backend> <server> <ip> <port>"
  exit
fi

if test -z "${4}"; then
  echo "#! Missing argument <port>: ./tool/haproxy-server-add.sh <backend> <server> <ip> <port>"
  exit
fi

SERV_BACKEND=${1}
SERV_NAME=${2}
SERV_IP=${3}
SERV_PORT=${4}
conffile=/etc/haproxy/haproxy.cfg

echo " Adding new server '${SERV_NAME}' with address '${SERV_IP}:${SERV_PORT}' to backend '${SERV_BACKEND}'"

backed_info=$(awk "/^backend ${SERV_BACKEND}/,/#----/" ${conffile})

if test -z "${backed_info}"; then
  echo " #! backend not found"
  exit
fi

if echo "${backed_info}" | grep -q "default-server.*"; then
  echo "   Defaults:      $(echo "${backed_info}" | grep -e "default-server.*" | sed 's/  */ /g' | cut -f3- -d" ")"
fi

echo "   Servers:       $(echo "${backed_info}" | grep -o "^    server .*" | wc -l)"
echo "   Server Tpls:   $(echo "${backed_info}" | grep -o "^    server-template .*" | wc -l)"

if echo "${backed_info}" | grep -q "server-template ${SERV_NAME} .*"; then

  #if (echo "show servers state loadbalancer" | socat stdio /var/run/haproxy.sock | grep -q " ${SERV_IP} "); then
  #  echo " ✓ Server with IP already exists"
  #  exit
  #fi

  echo " > using server-template"

  serverinfo="$(echo "${backed_info}" | grep -P -o -e "server-template ${SERV_NAME}.*")"
  serverinfo="$(echo "${serverinfo}" | sed 's/  */ /g')"

  RANGE_START=$(echo "${serverinfo}" | cut -f3 -d" " | cut -f1 -d"-")
  RANGE_END=$(echo "${serverinfo}" | cut -f3 -d" " | cut -f2 -d"-")
  DYN_SERV_NO=false
  for i in $(seq ${RANGE_START} ${RANGE_END});
  do
    DYN_SERV_INFO=$(echo "show servers state ${SERV_BACKEND}" | socat stdio /var/run/haproxy.sock | grep -e "${SERV_NAME}${i} ")
    srv_op_state=$(echo "${DYN_SERV_INFO}" | cut -f6 -d" ") # srv_op_state, 5 = init
    srv_admin_state=$(echo "${DYN_SERV_INFO}" | cut -f7 -d" ") # srv_admin_state, 5 = init, 4=ready
    if [ ${srv_admin_state} = 5 ]; then
      DYN_SERV_NO=${i}
      echo " > selected inactive server: ${SERV_BACKEND}/${SERV_NAME}${DYN_SERV_NO}"
      break
    fi
  done

  if [[ ${DYN_SERV_NO} = false ]]; then
    echo " ! couldn't find an inactive server in range ${RANGE_START}-${RANGE_END}"
    exit
  fi

  DYN_SERV_INFO=$(echo "show servers state ${SERV_BACKEND}" | socat stdio /var/run/haproxy.sock | grep -e "${SERV_NAME}${DYN_SERV_NO} ")
  srv_addr=$(echo "${DYN_SERV_INFO}" | cut -f5 -d" ") # srv_addr
  srv_op_state=$(echo "${DYN_SERV_INFO}" | cut -f6 -d" ") # srv_op_state, 5 = init
  srv_admin_state=$(echo "${DYN_SERV_INFO}" | cut -f7 -d" ") # srv_admin_state, 5 = init, 4=ready
  srv_port=$(echo "${DYN_SERV_INFO}" | cut -f19 -d" ") # srv_port

  if [ ${srv_port} != ${SERV_PORT} ]; then
    echo "set server ${SERV_BACKEND}/${SERV_NAME}${DYN_SERV_NO} port ${SERV_PORT}" | socat stdio /var/run/haproxy.sock
  fi
  if [ ${srv_addr} != ${SERV_IP} ]; then
    echo "set server ${SERV_BACKEND}/${SERV_NAME}${DYN_SERV_NO} addr ${SERV_IP}" | socat stdio /var/run/haproxy.sock
  fi

  echo "set server ${SERV_BACKEND}/${SERV_NAME}${DYN_SERV_NO} state ready" | socat stdio /var/run/haproxy.sock

  echo " ✓ Server ${SERV_BACKEND}/${SERV_NAME}${DYN_SERV_NO} is ready"

  echo "show servers state" | socat stdio /var/run/haproxy.sock > /etc/haproxy/haproxy.state
else
  echo "   > using server"
  # todo: sed insert new server
  # restart haproxy
  # bad-practicee
fi
