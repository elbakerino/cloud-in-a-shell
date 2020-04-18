#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

# Configure PHP CLI
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHP_V}/cli/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHP_V}/cli/php.ini
sed -i "s/memory_limit = .*/memory_limit = ${PHP_CLI_MEM_LIMIT}/" /etc/php/${PHP_V}/cli/php.ini
sed -i "s/;date.timezone.*/date.timezone = ${PHP_CLI_TIMEZONE}/" /etc/php/${PHP_V}/cli/php.ini

echo " ✓ PHP${PHP_V} CLI Settings"
