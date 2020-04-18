#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

source ${DIR_CUR}/state_init.sh

if ! test -f "${DIR_CUR}/../../state_init.sh"; then
  cp ${DIR_CUR}/state_init.sh ${DIR_CUR}/../../state_init.sh
fi

source ${DIR_CUR}/../../state_init.sh

function updateState() {
  sed -i "s/${1}=false/${1}=true/" ${DIR_CUR}/../../state_init.sh
}
