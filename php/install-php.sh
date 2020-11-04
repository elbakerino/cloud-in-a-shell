#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

# PHP
apt install -yq php${PHP_V} php${PHP_V}-fpm \
  php${PHP_V}-common php${PHP_V}-cli php${PHP_V}-mbstring php${PHP_V}-bcmath php${PHP_V}-curl php${PHP_V}-imap \
	php${PHP_V}-mysql php${PHP_V}-pdo php${PHP_V}-pgsql \
	php${PHP_V}-opcache \
	php${PHP_V}-gd php${PHP_V}-imagick \
	php${PHP_V}-intl php${PHP_V}-readline php${PHP_V}-pspell php${PHP_V}-tidy php${PHP_V}-xsl \
	php${PHP_V}-apcu php${PHP_V}-memcached \
	php${PHP_V}-xml php${PHP_V}-zip php${PHP_V}-json

# todo: apc is not available by default on 20, but on 18, on 20 only apcu
#php${PHP_V}-apc
# Install Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Setup PHP Configs
source ${DIR_CUR}/php-cli.sh

source ${DIR_CUR}/php-fpm.sh

echo " ✓ Installed PHP v${PHP_V}"
INSTALLED_PHP=true
sed -i "s/INSTALLED_PHP=false/INSTALLED_PHP=true/" ${DIR_CUR}/../../state_init.sh
