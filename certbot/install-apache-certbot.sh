#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

apt install -y certbot python-certbot-apache

# init certbot for manual user input
#certbot --apache

# check automation renew of certification
#certbot renew --dry-run

echo " ✓ certbot Apache"
SETUP_CERTBOT_APACHE=true
sed -i "s/SETUP_CERTBOT_APACHE=false/SETUP_CERTBOT_APACHE=true/" ${DIR_CUR}/../../state_init.sh


# updating an existing cert, adding more domains to the same cert:
# certbot --expand -d existing.com,example.com,newdomain.com
# certbot --expand -d existing.com -d example.com -d newdomain.com

# list existing certs
# certbot certificates

# change email address
# certbot -m
# certbot --agree-tos


# certbot run --apache -n -d example.org -d dev.example.org --expand --agree-tos -m hostmaster@example.com
