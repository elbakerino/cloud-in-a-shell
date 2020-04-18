#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

HOSTNAME=$(hostname --fqdn)

if test -z "${1}"
then
  SERVER_PAGE_PATH=html
else
  # todo: add vhost dir by vhost-name
  SERVER_PAGE_PATH=vhosts/${1}
fi

mkdir -p /var/www/${SERVER_PAGE_PATH}
cat >/var/www/${SERVER_PAGE_PATH}/index.html <<EOF
<!DOCTYPE html>
<html style="background: #071716">
<head>
  <meta charset="UTF-8"/>
  <title></title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
<p style="text-align: center; font-family: Consolas, monospace; color: #7ed7d1; display: flex; align-content: center;">
  <span style="margin: auto 0 auto auto;">I'm a</span> <span style="font-size: 3rem; margin: auto auto auto 4px">🍵</span>
</p>
<p style="text-align: center; font-family: Consolas, monospace; color: #266460">on <i>${HOSTNAME}</i></p>
<p style="text-align: center; font-family: Consolas, monospace; color: #266460"><small>by serverinits</small></p>
</body>
</html>
EOF

chown -R www-data:www-data /var/www/${SERVER_PAGE_PATH}

echo " ✓ Server Page: /var/www/${SERVER_PAGE_PATH}/index.html"
SETUP_SERVER_PAGE=true
sed -i "s/SETUP_SERVER_PAGE=false/SETUP_SERVER_PAGE=true/" ${DIR_CUR}/../../state_init.sh
