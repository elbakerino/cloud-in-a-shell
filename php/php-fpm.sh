#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

# Configure PHP/PHP-FPM
sed -i "s/error_reporting = .*/error_reporting = E_ALL \& ~E_NOTICE \& ~E_STRICT \& ~E_DEPRECATED/" /etc/php/${PHP_V}/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = Off/" /etc/php/${PHP_V}/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = ${PHP_MEM_LIMIT}/" /etc/php/${PHP_V}/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = ${PHP_MAX_UPLOAD}/" /etc/php/${PHP_V}/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = ${PHP_MAX_UPLOAD}/" /etc/php/${PHP_V}/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = ${PHP_TIMEZONE}/" /etc/php/${PHP_V}/fpm/php.ini

sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/${PHP_V}/fpm/pool.d/www.conf
sed -i "s/;request_terminate_timeout.*/request_terminate_timeout = ${PHP_MAX_REQ_TIME}/" /etc/php/${PHP_V}/fpm/pool.d/www.conf
# this config should not be needed, because apache got `mpm_event` configured
#sed -i "s/pm\.max_children.*/pm.max_children = 70/" /etc/php/${PHP_V}/fpm/pool.d/www.conf
#sed -i "s/pm\.start_servers.*/pm.start_servers = 20/" /etc/php/${PHP_V}/fpm/pool.d/www.conf
#sed -i "s/pm\.min_spare_servers.*/pm.min_spare_servers = 20/" /etc/php/${PHP_V}/fpm/pool.d/www.conf
#sed -i "s/pm\.max_spare_servers.*/pm.max_spare_servers = 35/" /etc/php/${PHP_V}/fpm/pool.d/www.conf
#sed -i "s/;pm\.max_requests.*/pm.max_requests = 500/" /etc/php/${PHP_V}/fpm/pool.d/www.conf

systemctl restart php${PHP_V}-fpm

echo " ✓ PHP${PHP_V} FPM Settings"
