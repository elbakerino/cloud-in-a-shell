#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

if [ ${OS} = "Ubuntu" ]; then
  if ! { [ $(isPkgInstalled certbot) ] || [ $(isPkgInstalled python-certbot-nginx) ]; }; then
    apt install -yq certbot python-certbot-nginx
  fi

  certbot certificates

elif [ ${OS} = "CentOS" ]; then
  if ! test -f "/usr/local/bin/certbot-auto"; then
    source ${DIR_CUR}/install-centos.sh
  fi

  /usr/local/bin/certbot-auto certificates

  # Setup auto renewal
  echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/certbot-auto renew" | sudo tee -a /etc/crontab >/dev/null
fi

echo " ✓ certbot NGINX"
SETUP_CERTBOT_NGINX=true
updateState "SETUP_CERTBOT_NGINX"
