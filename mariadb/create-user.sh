#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

read -p "Enter the username: " db_user

if sql mysql localhost root "select host,user from mysql.user;" | grep -q "${db_user}"; then
  echo "  User exists, exit."
  exit
fi

read -p "Enter user scope (default: localhost): " db_user_scope

if test -z "${db_user_scope}"; then
  db_user_scope='localhost'
fi

if test -z "${db_name}"; then
  db_name='*'
fi

read -sp "Enter new password: " db_pass

if test -z "${db_pass}"; then
  echo "#! Password is empty"
  exit
fi

sql mysql localhost root "CREATE USER '${db_user}'@'${db_user_scope}' IDENTIFIED BY '${db_pass}';"
# todo: dynamic privileges
sql mysql localhost root "GRANT SELECT, INSERT, DELETE, UPDATE ON ${db_name}.* TO '${db_user}'@'${db_user_scope}';"

# todo: check for error problems
echo "Created user ${db_user} for database: ${db_name}"
