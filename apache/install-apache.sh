#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

# Install + Configure Apache2
apt install -yq apache2 apache2-utils

sed -i "s/ServerTokens OS/ServerTokens Prod/" /etc/apache2/conf-available/security.conf
sed -i "s/ServerSignature On/ServerSignature Off/" /etc/apache2/conf-available/security.conf

# Create Webspace Dirs
echo "Using Apache log dir: "${APACHE_LOG_DIR}

mkdir ${APACHE_LOG_DIR}

chown www-data:www-data /var/www/html
chown www-data:www-data ${APACHE_LOG_DIR}
chown www-data:www-data /var/www
chmod -R g+rw /var/www

# Configure Apache Performance
source ${DIR_CUR}/../tool/apache-performance.sh 1

# Enable Apache Mods
a2enmod suexec rewrite ssl actions include cgi actions proxy_fcgi alias

# Setup Default
rm /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-available/000-default.conf
touch /etc/apache2/sites-available/default.conf
ln -s /etc/apache2/sites-available/default.conf /etc/apache2/sites-enabled/default.conf

# todo: setup log rotation
# todo: setup log-to-network

systemctl restart apache2

echo " ✓ Installed Apache"
INSTALLED_APACHE=true
sed -i "s/INSTALLED_APACHE=false/INSTALLED_APACHE=true/" ${DIR_CUR}/../../state_init.sh
