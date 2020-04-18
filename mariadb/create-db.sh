#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

read -p "Enter the database name: " db_name

if test -z "${db_name}"; then
  echo "db name must not be empty"
  exit
fi

sql mysql localhost root "CREATE DATABASE IF NOT EXISTS ${db_name};"

read -p "Create user for this database? (y|N) " create_user

if [[ ${create_user} == "y" ]] || [[ ${create_user} == "Y" ]]; then
  source ${DIR_CUR}/create-user.sh
fi
