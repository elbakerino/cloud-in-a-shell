#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

source ${DIR_CUR}/../tool/basics-ubuntu.sh

source ${DIR_CUR}/../apache/install-apache.sh

source ${DIR_CUR}/../php/install-php.sh

# enable php-fpm in apache
ln -s /etc/apache2/conf-available/php${PHP_V}-fpm.conf /etc/apache2/conf-enabled/php${PHP_V}-fpm.conf
systemctl reload apache2

source ${DIR_CUR}/../tool/setup-page.sh

# Prometheus monitoring exporter
source ${DIR_CUR}/../prometheus/exporter-apache.sh
source ${DIR_CUR}/../prometheus/exporter-node.sh

source ${DIR_CUR}/../prometheus/network-node.sh
source ${DIR_CUR}/../prometheus/network-apache.sh
