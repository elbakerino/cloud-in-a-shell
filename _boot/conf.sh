#!/bin/bash

# use ./conf-set.sh to modify config

TIMEZONE=UTC

APACHE_LOG_DIR=/var/www/logs

PHP_V=7.4
PHP_MEM_LIMIT=1024M
PHP_MAX_UPLOAD=256M
PHP_TIMEZONE=${TIMEZONE}
PHP_MAX_REQ_TIME=60

PHP_CLI_TIMEZONE=${PHP_TIMEZONE}
PHP_CLI_MEM_LIMIT=${PHP_MEM_LIMIT}

# Default Networking

# Default Networking used for server-template 'loadbalancer/websrv'
NET_WEBSRV=10.0.0.0
NET_WEBSRV_PORT=80

# Gateways to individual Services
NET_MONIT=10.0.0.0
GW_MONIT=10.0.0.1

NET_SERVICE_DISCOVERY=10.0.0.0
GW_SERVICE_DISCOVERY=10.0.0.1

SD_NODES="10.0.0.2 10.0.0.3 10.0.0.4"
SD_KEY=false

# copy this file one dir up
# cp conf.sh ../../
# then change variables there to overwrite defaults
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
if test -f "${DIR_CUR}/../../conf.sh"; then
  source "${DIR_CUR}/../../conf.sh"
fi
