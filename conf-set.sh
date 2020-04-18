#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

if ! test -f "${DIR_CUR}/../conf.sh"; then
  cp "${DIR_CUR}/_boot/conf.sh" "${DIR_CUR}/../conf.sh"
fi

# Usage:
#
# ./conf-set.sh --php-timezone="UTC"
#

echo "Changing Defaults used by scripts."
echo " > Not the runtime programs config!"

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
    case $PARAM in
        --php-mem-lim)
          echo "   Change: PHP_MEM_LIMIT from '$(cat "${DIR_CUR}/../conf.sh" | grep -o "PHP_MEM_LIMIT=.*" | cut -f2 -d=)' to '${VALUE}'"
          sed -i "s~PHP_MEM_LIMIT=.*~PHP_MEM_LIMIT=${VALUE}~" ${DIR_CUR}/../conf.sh
          ;;
        --php-max-upload)
          echo "   Change: PHP_MAX_UPLOAD from '$(cat "${DIR_CUR}/../conf.sh" | grep -o "PHP_MAX_UPLOAD=.*" | cut -f2 -d=)' to '${VALUE}' (used for upload_max_filesize and post_max_size)"
          sed -i "s~PHP_MAX_UPLOAD=.*~PHP_MAX_UPLOAD=${VALUE}~" ${DIR_CUR}/../conf.sh
          ;;
        --php-timezone)
          echo "   Change: PHP_TIMEZONE from '$(cat "${DIR_CUR}/../conf.sh" | grep -o "PHP_TIMEZONE=.*" | cut -f2 -d=)' to '${VALUE}'"
          sed -i "s~PHP_TIMEZONE=.*~PHP_TIMEZONE=${VALUE}~" ${DIR_CUR}/../conf.sh
          ;;
        --php-max-req)
          echo "   Change: PHP_MAX_REQ_TIME from '$(cat "${DIR_CUR}/../conf.sh" | grep -o "PHP_MAX_REQ_TIME=.*" | cut -f2 -d=)' to '${VALUE}'"
          sed -i "s~PHP_MAX_REQ_TIME=.*~PHP_MAX_REQ_TIME=${VALUE}~" ${DIR_CUR}/../conf.sh
          ;;
        --net-websrv)
          echo "   Change: NET_WEBSRV from '$(cat "${DIR_CUR}/../conf.sh" | grep -o "NET_WEBSRV=.*" | cut -f2 -d=)' to '${VALUE}'"
          sed -i "s~NET_WEBSRV=.*~NET_WEBSRV=${VALUE}~" ${DIR_CUR}/../conf.sh
          ;;
        --net-websrv-port)
          echo "   Change: NET_WEBSRV_PORT from '$(cat "${DIR_CUR}/../conf.sh" | grep -o "NET_WEBSRV_PORT=.*" | cut -f2 -d=)' to '${VALUE}'"
          sed -i "s~NET_WEBSRV_PORT=.*~NET_WEBSRV_PORT=${VALUE}~" ${DIR_CUR}/../conf.sh
          ;;
        --net-service-discovery)
          echo "   Change: NET_SERVICE_DISCOVERY from '$(cat "${DIR_CUR}/../conf.sh" | grep -o "NET_SERVICE_DISCOVERY=.*" | cut -f2 -d=)' to '${VALUE}'"
          sed -i "s~NET_SERVICE_DISCOVERY=.*~NET_SERVICE_DISCOVERY=${VALUE}~" ${DIR_CUR}/../conf.sh
          ;;
        --gw-service-discovery)
          echo "   Change: GW_SERVICE_DISCOVERY from '$(cat "${DIR_CUR}/../conf.sh" | grep -o "GW_SERVICE_DISCOVERY=.*" | cut -f2 -d=)' to '${VALUE}'"
          sed -i "s~GW_SERVICE_DISCOVERY=.*~GW_SERVICE_DISCOVERY=${VALUE}~" ${DIR_CUR}/../conf.sh
          ;;
        --net-monit)
          echo "   Change: NET_MONIT from '$(cat "${DIR_CUR}/../conf.sh" | grep -o "NET_MONIT=.*" | cut -f2 -d=)' to '${VALUE}'"
          sed -i "s~NET_MONIT=.*~NET_MONIT=${VALUE}~" ${DIR_CUR}/../conf.sh
          ;;
        --sd-nodes)
          echo "   Change: SD_NODES from '$(cat "${DIR_CUR}/../conf.sh" | grep -o "SD_NODES=.*" | cut -f2 -d= | sed -e 's/"//g')' to '${VALUE}'"
          sed -i "s~SD_NODES=.*~SD_NODES=\"${VALUE}\"~" ${DIR_CUR}/../conf.sh
          ;;
        --sd-key)
          echo "   Change: SD_KEY from '$(cat "${DIR_CUR}/../conf.sh" | grep -o "SD_KEY=.*" | cut -f2 -d= | sed -e 's/"//g')' to '${VALUE}'"
          sed -i "s~SD_KEY=.*~SD_KEY=\"${VALUE}\"~" ${DIR_CUR}/../conf.sh
          ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""

            exit 1
            ;;
    esac
    shift
done
