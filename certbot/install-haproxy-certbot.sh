#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

if ! test -f "/usr/local/bin/certbot-auto"; then
  wget https://dl.eff.org/certbot-auto
  mv certbot-auto /usr/local/bin/certbot-auto
  chown root /usr/local/bin/certbot-auto
  chmod 0755 /usr/local/bin/certbot-auto
fi

CERT_NAME=${1}
if test -z "${CERT_NAME}"
then
  echo "#! Missing argument cert-name: ./setup/certbot-haproxy.sh <name> <email> [<(new)-host>]"
  exit
fi

EMAIL=${2}
NEW_NAME=${3}

HOSTS=""
if test -f "/etc/letsencrypt/live/${CERT_NAME}/fullchain.pem"
then
  SSL_INFO="$(openssl x509 -in /etc/letsencrypt/live/${CERT_NAME}/fullchain.pem -text)"
  SUBJECT_CN=$(echo "${SSL_INFO}" | grep -o "Subject: CN.*" | cut -f2- -d"=")
  SUBJECT_ALTERNATE=$(echo "${SSL_INFO}" | grep -A1 "Subject Alternative Name.*" | cut -f2- -d":")
  while IFS=',' read -ra ADDR; do
    for alias in "${ADDR[@]}"; do
      alias=$(echo "${alias}" | sed 's/ *//g')
      if ! test -z "${alias}"; then
        HOST=$(sed -e "s/DNS://" <<<${alias})
        HOSTS="${HOSTS} -d ${HOST}"
      fi
    done
  done<<<"${SUBJECT_ALTERNATE}"
fi

if test -z "${HOSTS}"; then
  if test -z "${NEW_NAME}"
  then
    echo " X No hosts existing and none added"
    exit
  fi
fi

if ! test -z "${NEW_NAME}"
then
  HOSTS="-d ${NEW_NAME} ${HOSTS}"
fi

SERV_NAMES=${HOSTS}
echo "   Using Hosts: $(sed -e "s/\-d //g" <<<${SERV_NAMES})"
if test -z "${EMAIL}"
then
  echo "   Create/Expanding cert '${CERT_NAME}'..."
  echo ""
  /usr/local/bin/certbot-auto certonly --webroot -n --webroot-path "/var/lib/haproxy/docroot" \
      --cert-name ${CERT_NAME} -n ${SERV_NAMES} --expand --agree-tos
else
  echo "   Create/Expanding cert '${CERT_NAME}' with warning email '${EMAIL}'..."
  echo ""
  /usr/local/bin/certbot-auto certonly --webroot -n --webroot-path "/var/lib/haproxy/docroot" \
      --cert-name ${CERT_NAME} -n ${SERV_NAMES} --expand --agree-tos -m ${EMAIL}
fi

cat /etc/letsencrypt/live/${CERT_NAME}/fullchain.pem /etc/letsencrypt/live/${CERT_NAME}/privkey.pem > /etc/haproxy/certs/${CERT_NAME}.pem
if test -f "/etc/haproxy/certs/${CERT_NAME}.pem"; then
  echo "   Created combined file /etc/haproxy/certs/${CERT_NAME}.pem"
else
  echo " X Failed to create combined file /etc/haproxy/certs/${CERT_NAME}.pem"
fi


echo " ✓ certbot HAProxy"
SETUP_CERTBOT_HAPROXY=true
sed -i "s/SETUP_CERTBOT_HAPROXY=false/SETUP_CERTBOT_HAPROXY=true/" ${DIR_CUR}/../../state_init.sh
