#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

# commenting the line `bind-address` should also work
if [ ${OS} = "Ubuntu" ]; then
  sed -i "s/#skip-networking .*/skip-networking/" /etc/mysql/my.cnf
  sed -i "s/bind-address .*/bind-address 0.0.0.0/" /etc/mysql/my.cnf
elif [ ${OS} = "CentOS" ]; then
  sed -i "s/#skip-networking .*/skip-networking/" /etc/my.cnf
  sed -i "s/bind-address .*/bind-address 0.0.0.0/" /etc/my.cnf
fi

echo " ✓ Allowed MySQL Remote Access"
