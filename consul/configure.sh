#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

CONSUL_UI=false
CONSUL_SERVER=false
CONSUL_DC=false
CONSUL_EXPECT=false

DO_RESTART=false
DO_DEFAULTS=false

while [ "$1" != "" ]; do
  PARAM=$(echo $1 | awk -F= '{print $1}')
  VALUE=$(echo $1 | awk -F= '{print $2}')
  DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
  case $PARAM in
  --ui)
    CONSUL_UI=true
    ;;
  --server)
    CONSUL_SERVER=true
    ;;
  --dc)
    CONSUL_DC=${VALUE}
    ;;
  --expect)
    CONSUL_EXPECT=${VALUE}
    ;;
  --restart)
    DO_RESTART=true
    ;;
  --defaults)
    DO_DEFAULTS=true
    ;;
  *)
    # ignoring unkown
    printf ""
    ;;
  esac
  shift
done

if [[ ${CONSUL_DC} = false ]];then
  # use existing DC when not specified or use default
  if [[ ${DO_DEFAULTS} = false ]] && test -f "/etc/consul.d/config.json" && ! grep -q "%datacenter%" /etc/consul.d/config.json; then
    CONSUL_DC=$(grep -o "datacenter\":.*" /etc/consul.d/config.json | cut -f2 -d: | sed -E "s/(\"|,| )//g")
  else
    CONSUL_DC="DC1"
  fi
fi

if [[ ${CONSUL_EXPECT} = false ]];then
  # use existing DC when not specified or use default
  if [[ ${DO_DEFAULTS} = false ]] && test -f "/etc/consul.d/config.json" && ! grep -q "%bootstrap_expect%" /etc/consul.d/config.json; then
    CONSUL_EXPECT=$(grep -o "bootstrap_expect\":.*" /etc/consul.d/config.json | cut -f2 -d: | sed -E "s/(\"|,| )//g")
  else
    CONSUL_EXPECT=1
  fi
fi

OWN_PRIV_IP=$(getOwnIP ${GW_SERVICE_DISCOVERY})
if [ ! $? -eq 0 ]; then
  echo ${OWN_PRIV_IP}
  exit 1
fi

echo "   SD Gateway:    ${GW_SERVICE_DISCOVERY}"
echo "   Own IP:        ${OWN_PRIV_IP}"

NODE_SERVICE=$(cat "${DIR_CUR}/node.service" |
  sed -e "s/%node%/${OWN_PRIV_IP}/")

touch /etc/systemd/system/consul.service
cat >/etc/systemd/system/consul.service <<EOF
${NODE_SERVICE}
EOF

# building json-array
echo "   Consul Nodes:"
SD_NODES_TMP="["
for node in ${SD_NODES}; do
  SD_NODES_TMP="${SD_NODES_TMP}"' "'"${node}"'",'
  echo "                  ${node}"
done

SD_NODES_TMP="${SD_NODES_TMP} "'"'"${OWN_PRIV_IP}"'" ]'

echo "   Consul UI:     ${CONSUL_UI}"
echo "   Consul Server: ${CONSUL_SERVER}"
echo "   Consul Expect: ${CONSUL_EXPECT}"
echo "   Datacenter:    ${CONSUL_DC}"

NODE_JSON=$(cat "${DIR_CUR}/node.json" |
  sed -e "s/%advertise_addr%/${OWN_PRIV_IP}/" |
  sed -e "s/%bind_addr%/${OWN_PRIV_IP}/" |
  sed -e "s/%client_addr%/0.0.0.0/" |
  #sed -e "s/%client_addr%/127.0.0.1/" |
  sed -e "s/%bootstrap_expect%/${CONSUL_EXPECT}/" |
  sed -e "s/%ui%/${CONSUL_UI}/" |
  sed -e "s/%server%/${CONSUL_SERVER}/" |
  sed -e "s/%datacenter%/${CONSUL_DC}/" |
  sed -e "s/%encrypt%/$(echo ${SD_KEY} | sed 's/=//g' | sed 's/\//\\\//g')=/" |
  sed -e "s/%start_join%/${SD_NODES_TMP}/" |
  sed -e "s/%retry_join%/${SD_NODES_TMP}/")

touch /etc/consul.d/config.json
cat >/etc/consul.d/config.json <<EOF
${NODE_JSON}
EOF

systemctl daemon-reload

echo ""
echo " ✓ Reconfigured Consul"

if [[ ${DO_RESTART} = true ]]; then
  systemctl restart consul
  echo " ✓ Restarted Consul"
fi
