#!/bin/bash

function isPkgInstalled() {
  dpkg-query -W -f='${Status}' ${1} 2>/dev/null | grep "ok installed" -q
}

function sql() {
  # 1 == DB_NAME
  # 2 == DB_HOST
  # 3 == DB_USER
  # 4 == DB_PASS (or query)
  # 5 == actual query (or nothing)

  if test -z "${5}"; then
    mysql -D ${1} -h ${2} -u${3} --skip-column-names -e "${4}"
  else
    mysql -D ${1} -h ${2} -u${3} -p${4} --skip-column-names -e "${5}"
  fi
}
