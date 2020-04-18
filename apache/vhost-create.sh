#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

VHOST_NAME=${1}
VHOST_SERVERNAME=${2}
VHOST_DOCROOT=/var/www/vhosts/${1}

mkdir -p ${VHOST_DOCROOT}
chown www-data:www-data -R ${VHOST_DOCROOT}

# todo: clean already existing at first *-ssl.conf *-le-ssl.conf
# todo: warn before clean already existing files

# todo: make ServerAdmin dynamic
cat >/etc/apache2/sites-available/${VHOST_NAME}.conf <<EOF
<VirtualHost *:80>
    ServerName ${VHOST_SERVERNAME}
    AllowEncodedSlashes On
    DocumentRoot ${VHOST_DOCROOT}
    ServerAdmin webmaster@localhost

    <Directory "${VHOST_DOCROOT}">
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride all
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error_${VHOST_NAME}.log
    CustomLog ${APACHE_LOG_DIR}/access_${VHOST_NAME}.log combined
</VirtualHost>
EOF

cat >${VHOST_DOCROOT}/index.html <<EOF
Created!
EOF

a2ensite ${VHOST_NAME}.conf

# todo: check if really needed, maybe also needed add `add-alias`
# echo -e "127.0.0.1 \t ${VHOST_SERVERNAME}" >> /etc/hosts

systemctl reload apache2

# cat /etc/apache2/sites-available/${VHOST_NAME}.conf

echo " ✓ vhost ${VHOST_NAME} created"
echo "   > to disable:  ./apache/vhost-dis.sh ${VHOST_NAME}"
echo "   > to rm:       ./apache/vhost-rm.sh ${VHOST_NAME}"
echo "   > to list all: ./apache/vhost-list.sh"
