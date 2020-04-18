#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

echo "Apache vhosts:"

for i in /etc/apache2/sites-available/*.conf; do

  filename=$(basename -- "${i}")
  extension="${filename##*.}"
  filename="${filename%.*}"
  conffile=/etc/apache2/sites-available/${filename}.conf
  conffile_le=/etc/apache2/sites-available/${filename}-le-ssl.conf

  if [[ ${filename} != *"-ssl"* ]]; then
    echo " > ${filename}"
    LE_ACTIVE=false
    if test -f "/etc/apache2/sites-available/${filename}-ssl.conf"; then
      echo "   ✓ SSL"
    else
      if test -f "${conffile_le}"; then
        LE_ACTIVE=true
        echo "   ✓ SSL by Let's Encrypt"
      else
        echo "   X SSL"
      fi
    fi

    if grep -q "RewriteRule ^ https://%" "${conffile}"; then
      echo "   ✓ Redir to SSL"
    fi

    if grep -q "DocumentRoot" "${conffile}"; then
      echo "   DocumentRoot: $(cat ${conffile} | grep -o "DocumentRoot.*" | cut -f2- -d" ")"
    fi

    if test -f "${conffile_le}"; then
      SSL_INFO="$(openssl x509 -in /etc/letsencrypt/live/${filename}/fullchain.pem -text)"
      SUBJECT_CN=$(echo "${SSL_INFO}" | grep -o "Subject: CN.*" | cut -f2- -d"=")
      SUBJECT_ALTERNATE=$(echo "${SSL_INFO}" | grep -A1 "Subject Alternative Name.*" | cut -f2- -d":")
    fi

    if grep -q "ServerName" "${conffile}"; then
      SERV_NAME=$(cat ${conffile} | grep -o "ServerName.*" | cut -f2- -d" ")
      if grep -q "${SERV_NAME}" <<< ${SUBJECT_CN}; then
        SERV_NAME="${SERV_NAME} 🔒 SSL"
      else
        SERV_NAME="${SERV_NAME} 💥 NO SSL"
      fi
      echo "   ServerName:   ${SERV_NAME}"
    fi

    if grep -q "ServerAlias" "${conffile}"; then
      echo "   ServerAliase:"
      cat ${conffile} | grep -o "ServerAlias.*" | cut -f2- -d" " |
        while read serveralias; do
          if grep -q "${serveralias}" <<< ${SUBJECT_ALTERNATE}; then
            SERV_NAME="${serveralias} 🔒 SSL"
          else
            SERV_NAME="${serveralias} 💥 NO SSL"
          fi
          echo "                 ${SERV_NAME}"
        done
    fi

    # todo: basicauth check 🔑
    if grep -q "ErrorLog" "${conffile}"; then
      echo "   ErrorLog:     $(cat ${conffile} | grep -o "ErrorLog.*" | cut -f2- -d" ")"
    fi
    if grep -q "CustomLog" "${conffile}"; then
      echo "   CustomLog:    $(cat ${conffile} | grep -o "CustomLog.*" | cut -f2- -d" " | cut -f1 -d" ")"
    fi

    echo ""
  fi
done
