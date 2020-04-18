#!/bin/bash

if [[ ${BOOTED} != true ]]; then
  DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
  source ${DIR_CUR}/_boot/os-check.sh
  DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
  source ${DIR_CUR}/_boot/conf.sh
  DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
  source ${DIR_CUR}/_boot/state_init_load.sh
  DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
  source ${DIR_CUR}/_boot/functions.sh
  DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

  BOOTED=true
fi
