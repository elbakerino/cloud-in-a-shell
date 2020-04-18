#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

if [ ${OS} = "Ubuntu" ]; then
  my_cnf=/etc/mysql/my.cnf
elif [ ${OS} = "CentOS" ]; then
  my_cnf=/etc/my.cnf
else
  echo "#! Unsupported OS"
  exit
fi

function mysqlChange() {
  var_name=${1}
  var_insert_after=${2} # optional
  do_update=''
  var_new=''
  # todo: only used 'match1', should warn when multiple per file
  var_current=$(grep -om1 "^${var_name}.*" ${my_cnf} | cut -f2 -d"=" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  read -p " Change ${var_name}? [${var_current}] " var_new

  if test -z "${var_new}"; then
    var_new=${var_current}
  fi

  if test -z "${var_current}"; then
    if test -z "${var_new}"; then
      echo "#! Can not create ${var_new}, please enter a new value"
    else
      if test -z "${var_insert_after}"; then
        echo "#! Can not create ${var_name}, does not exist and unkown where to add."
      else
        sed -i "/^${var_insert_after}.*/a ${var_name} = ${var_new}" ${my_cnf}
      fi
    fi
  else
    sed -i "s/${var_name}.*/${var_name} = ${var_new}/" ${my_cnf}
  fi
}

mysqlChange max_connections
mysqlChange connect_timeout
mysqlChange wait_timeout

# todo: is in two different groups, server fine tuning and dump settings, schould be editable separatly
mysqlChange max_allowed_packet

mysqlChange thread_cache_size
mysqlChange sort_buffer_size
mysqlChange bulk_insert_buffer_size
mysqlChange tmp_table_size
mysqlChange max_heap_table_size
mysqlChange query_cache_limit
mysqlChange query_cache_size
mysqlChange long_query_time
mysqlChange expire_logs_days
mysqlChange innodb_buffer_pool_size default_storage_engine
mysqlChange innodb_log_buffer_size default_storage_engine
mysqlChange innodb_file_per_table default_storage_engine
mysqlChange innodb_read_io_threads default_storage_engine
mysqlChange innodb_open_files default_storage_engine
mysqlChange innodb_io_capacity default_storage_engine
mysqlChange innodb_thread_concurrency default_storage_engine

read -p " Restart MySQL? (y|N) " do_restart

if [[ ${do_restart} == "y" ]] || [[ ${do_restart} == "Y" ]]; then
  service mysql restart
  echo "Service MySQL restarted"
fi
