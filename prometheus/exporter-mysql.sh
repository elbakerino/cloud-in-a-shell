#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

echo "Installing Prometheus MySQL Exporter"

useradd -rs /bin/false mysqld_exporter

if ! test -f "/usr/local/bin/mysqld_exporter"; then
  V_MYSQL_EXPORTER=0.12.1
  wget https://github.com/prometheus/mysqld_exporter/releases/download/v${V_MYSQL_EXPORTER}/mysqld_exporter-${V_MYSQL_EXPORTER}.linux-amd64.tar.gz
  tar xvf mysqld_exporter-${V_MYSQL_EXPORTER}.linux-amd64.tar.gz
  cp mysqld_exporter-${V_MYSQL_EXPORTER}.linux-amd64/mysqld_exporter /usr/local/bin
  chown mysqld_exporter:mysqld_exporter /usr/local/bin/mysqld_exporter
  rm -rf mysqld_exporter-${V_mysqld_exporter}.linux-amd64.tar.gz mysqld_exporter-${V_mysqld_exporter}.linux-amd64
else
  echo "   Exporter already installed"
fi

# create exporter user

if test -f "/usr/local/bin/mysqld_exporter"; then

  read -p "  Exporter already exists, do update? (y|N)" do_update

  if [[ ${do_update} == "y" ]] || [[ ${do_update} == "Y" ]]; then
    do_update='y'
    echo ""
  else
    pass=$(grep -o "mysqld_exporter:*.*@tcp" /etc/systemd/system/mysqld_exporter.service | cut -f2 -d":" | rev | cut -c 5- | rev)
  fi
fi

if test -z "${pass}"; then
  read -sp "Enter password for exporter sql user: " pass

  if test -z "${pass}"; then
    echo "#! Password is empty"
    exit
  fi
fi

if sql mysql localhost root "select host,user from mysql.user;" | grep -q "mysqld_exporter"; then
  if [[ ${do_update} == "y" ]]; then
    echo ""
    echo "Updating user password"
    sql mysql localhost root "SET PASSWORD FOR 'mysqld_exporter'@'localhost' = PASSWORD('${pass}');"
    sql mysql localhost root "GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqld_exporter'@'localhost';"
    echo "Updated MySQL User 'mysqld_exporter'"
  fi
else
  echo ""
  echo "Creating User"
  sql mysql localhost root "CREATE USER 'mysqld_exporter'@'localhost' IDENTIFIED BY '${pass}';"
  sql mysql localhost root "GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqld_exporter'@'localhost';"

  echo ""
  echo "Created MySQL User 'mysqld_exporter'"
fi

# create service
cat >/etc/systemd/system/mysqld_exporter.service <<EOF
[Unit]
Description=MySQL Exporter Service
Wants=network.target
After=network.target

[Service]
User=mysqld_exporter
Group=mysqld_exporter
Environment="DATA_SOURCE_NAME=mysqld_exporter:${pass}@tcp(localhost:3306)/"
Type=simple
ExecStart=/usr/local/bin/mysqld_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start mysqld_exporter
systemctl enable mysqld_exporter

#
# CREATE USER 'mysqld_exporter'@'localhost' IDENTIFIED BY 'password' WITH MAX_USER_CONNECTIONS 3;
#
# use mysql;
# SET PASSWORD FOR 'mysqld_exporter'@'localhost' = PASSWORD('password');
#
# GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'mysqld_exporter'@'localhost';
#

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
echo " ✓ Prometheus MySQL Exporter"
INSTALLED_PROMETHEUS_EXPORTER_MYSQL=true
sed -i "s/INSTALLED_PROMETHEUS_EXPORTER_MYSQL=false/INSTALLED_PROMETHEUS_EXPORTER_MYSQL=true/" ${DIR_CUR}/../../state_init.sh
