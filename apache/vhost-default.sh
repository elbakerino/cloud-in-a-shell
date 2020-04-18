#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

# Apache VHOST Default
# todo: make ServerAdmin dynamic
cat >/etc/apache2/sites-available/default.conf <<EOF
<VirtualHost *:80>
    ServerName localhost
    AllowEncodedSlashes On
    DocumentRoot /var/www/html
    ServerAdmin webmaster@localhost

    <Directory "/var/www/html">
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride all
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

cat >/var/www/html/index.html <<EOF
Setup needed in <code>/var/www/html</code>
EOF

systemctl reload apache2

echo "✓ Apache Default VHOST"
