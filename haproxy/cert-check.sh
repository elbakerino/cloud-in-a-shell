#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

if ! test -f "/usr/local/bin/certbot"; then
  source ${DIR_CUR}/install-centos.sh
fi

EMAIL=${1}
if test -z "${EMAIL}"; then
  echo "No email set, add one for creating/updating certs: ./cert-check.sh <email>"
  echo ""
fi

conffile=$(bash -c "echo ~/haproxy.conf")
if ! test -f ${conffile}; then
  echo "File not found, create: ~/haproxy.conf"
  exit 1
fi

declare -A BACKEND_HOSTS
while read line; do
  if [[ $line =~ ^"["(.+)"]"$ ]]; then
    backend_name=${BASH_REMATCH[1]}
  elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then
    varname=${BASH_REMATCH[1]}
    varval=${BASH_REMATCH[2]}

    if [[ ${varname} == 'ssl_domains' ]]; then
      BACKEND_HOSTS[${backend_name}]="${varval}"
    fi
  fi
done <${conffile}

echo "Checking SSL Certificates:"

for backend_name in "${!BACKEND_HOSTS[@]}"; do
  #echo "value: ${BACKEND_HOSTS[${backend}]}"
  HOSTS=""
  CERT_HOSTS=""
  if test -f "/etc/letsencrypt/live/${backend_name}/fullchain.pem"; then
    SSL_INFO="$(openssl x509 -in /etc/letsencrypt/live/${backend_name}/fullchain.pem -text)"
    SUBJECT_CN=$(echo "${SSL_INFO}" | grep -o "Subject: CN.*" | cut -f2- -d"=")
    SUBJECT_ALTERNATE=$(echo "${SSL_INFO}" | grep -A1 "Subject Alternative Name.*" | cut -f2- -d":")
    while IFS=',' read -ra ADDR; do
      for alias in "${ADDR[@]}"; do
        alias=$(echo "${alias}" | sed 's/ *//g')
        if ! test -z "${alias}"; then
          HOST=$(sed -e "s/DNS://" <<<${alias})
          HOSTS="${HOSTS} ${HOST}"
        fi
      done
    done<<<"${SUBJECT_ALTERNATE}"

    echo "  Domains for '${backend_name}':"
    for i in ${BACKEND_HOSTS[${backend_name}]}; do
      CERT_HOSTS="${CERT_HOSTS} -d ${i}"
      if [[ $(echo ${HOSTS} | grep -o "\b${i}\b") ]]; then
        echo "    ✓ ${i}"
      else
        echo "    X ${i}"
      fi
    done

    for i in ${HOSTS}; do
      if ! [[ $(echo ${BACKEND_HOSTS[${backend_name}]} | grep -o "\b${i}\b") ]]; then
        echo "   ! not in haproxy conf: ${i}"
        CERT_HOSTS="${CERT_HOSTS} -d ${i}"
      fi
    done
  else
    echo "   ! ${backend_name} got no cert!"
  fi

  if ! test -z "${CERT_HOSTS}" && ! test -z "${EMAIL}"; then
    CERT_HOSTS="${CERT_HOSTS}"
    echo "    Creating/Updating with certbort:"

    echo "      Using Hosts: $(sed -e "s/\-d //g" <<<${CERT_HOSTS})"
    echo "      Create/Updating cert '${backend_name}' with warning email '${EMAIL}'..."
    echo ""

    echo "certbot certonly --cert-name ${backend_name} -n --webroot --webroot-path '/var/lib/haproxy/docroot' ${CERT_HOSTS} --expand --agree-tos -m ${EMAIL}"
    echo "certbot certonly --cert-name ${backend_name} -n --webroot --webroot-path '/var/lib/haproxy/docroot' ${CERT_HOSTS} --agree-tos -m ${EMAIL}"
    certbot certonly --cert-name ${backend_name} -n --agree-tos -m ${EMAIL} \
         --webroot -n --webroot-path "/var/lib/haproxy/docroot" ${CERT_HOSTS}

    if test -f "/etc/letsencrypt/live/${backend_name}/fullchain.pem" && test -f "/etc/letsencrypt/live/${backend_name}/privkey.pem"; then
      cat /etc/letsencrypt/live/${backend_name}/fullchain.pem /etc/letsencrypt/live/${backend_name}/privkey.pem > /etc/haproxy/certs/${backend_name}.pem
      if test -f "/etc/haproxy/certs/${backend_name}.pem"; then
        echo "    ✓ Created combined file /etc/haproxy/certs/${backend_name}.pem"
      else
        echo "    X Failed to create combined file /etc/haproxy/certs/${backend_name}.pem"
      fi
    fi
  fi
done
