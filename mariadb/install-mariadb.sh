#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
apt-add-repository 'deb [arch=amd64,arm64,ppc64el] http://mirror.netcologne.de/mariadb/repo/10.4/ubuntu bionic main'

apt update

apt install -yq mariadb-server

echo " ✓ Installed MariaDB"
INSTALLED_MARIADB=true
sed -i "s/INSTALLED_MARIADB=false/INSTALLED_MARIADB=true/" ${DIR_CUR}/../../state_init.sh
