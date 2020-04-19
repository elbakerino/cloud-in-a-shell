#!/bin/bash

DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${DIR_CUR}/../_boot.sh
DIR_CUR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

if [[ ${1} == 'ssl' ]]; then
  HAPROXY_SSL=1
fi

if ! test -f "/etc/haproxy/haproxy.cfg"; then
  touch /etc/haproxy/haproxy.cfg
fi

conffile=$(bash -c "echo ~/haproxy.conf")
if ! test -f ${conffile}; then
  echo "File not found, create: ~/haproxy.conf"
  exit 1
fi

DEFAULT_BACKEND=loadbalancer
STATS_PORT=8080
SERV_TPL=${NET_WEBSRV}
SERV_PORT=${NET_WEBSRV_PORT}

SSL_COMMENT='#'
if [[ ${HAPROXY_SSL} == 1 ]]; then
  SSL_COMMENT=''
  echo "Configuring HAProxy and turning SSL on"
else
  echo "Configuring HAProxy - no SSL!"
fi

cat >/etc/haproxy/haproxy.cfg <<EOF
#---------------------------------------------------------------------
# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   https://www.haproxy.org/download/1.8/doc/configuration.txt
#
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    # non syslog file logging:
    # log         /log/haproxy

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    log         127.0.0.1 local2 notice
    log         127.0.0.1 local3
    daemon

    server-state-file /etc/haproxy/haproxy.state

    # turn on cli socket
    stats socket /var/run/haproxy.sock expose-fd listeners level admin
    # turn on exporter socket
    stats socket /var/run/haproxy-exporter.sock mode 660 expose-fd listeners level admin

    # Static Server
    lua-load     /etc/haproxy/static-server.lua

    # utilize system-wide crypto-policies
    ssl-default-bind-ciphers   PROFILE=SYSTEM
    ssl-default-server-ciphers PROFILE=SYSTEM
    tune.ssl.default-dh-param  2048

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    # option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000
    load-server-state-from-file global
#---------------------------------------------------------------------
# HAProxy Monitoring Config
#---------------------------------------------------------------------
listen stats
    bind *:${STATS_PORT}
    # activate when activated ssl:
   ${SSL_COMMENT} bind *:${STATS_PORT} ssl crt /etc/haproxy/certs/
   ${SSL_COMMENT} reqadd X-Forwarded-Proto:\ https
    option forwardfor
    option httpclose
    stats enable
    stats show-legends
    stats refresh 5s
    # URL for HAProxy monitoring
    stats uri /stats
    stats realm Haproxy\ Statistics
    # User and Password for login to the monitoring dashboard
    stats auth admin:a21362@nm
    #stats admin if TRUE
    # This is optionally for monitoring backend
    default_backend ${DEFAULT_BACKEND}
#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend ${DEFAULT_BACKEND}
    bind *:80

    compression algo gzip
    compression type text/html text/plain text/javascript application/javascript application/xml text/css application/json
    option accept-invalid-http-request

    option http-server-close
    option forwardfor

    acl url_certbot       path_beg       -i /.well-known

   ${SSL_COMMENT} redirect scheme https code 301 if !url_certbot !{ ssl_fc }

	  # default_backend ${DEFAULT_BACKEND}

    use_backend certbot if url_certbot

# activate SSL after cert exists, otherwise haproxy service fails
${SSL_COMMENT}frontend www-https
${SSL_COMMENT}    bind *:443 ssl crt /etc/haproxy/certs/
${SSL_COMMENT}    reqadd X-Forwarded-Proto:\ https
${SSL_COMMENT}    option accept-invalid-http-request

${SSL_COMMENT}    #acl url_static        path_beg       -i /static /images /javascript /stylesheets
${SSL_COMMENT}    #acl url_static        path_end       -i .jpg .gif .png .css .js
${SSL_COMMENT}    #use_backend static    if url_static

EOF

while read line; do
  if [[ $line =~ ^"["(.+)"]"$ ]]; then
    backend_name=${BASH_REMATCH[1]}
  elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then
    varname=${BASH_REMATCH[1]}
    varval=${BASH_REMATCH[2]}

    if [[ ${varname} == 'acl_host' ]]; then
      echo "Allowing hosts for '${backend_name}': ${varval}"
      cat <<EOF >>/etc/haproxy/haproxy.cfg
${SSL_COMMENT}    acl host_${backend_name} hdr_end(host) -i ${varval}
EOF
    fi
  fi
done <${conffile}

cat <<EOF >>/etc/haproxy/haproxy.cfg

${SSL_COMMENT}    default_backend ${DEFAULT_BACKEND}
EOF

while read line; do
  if [[ $line =~ ^"["(.+)"]"$ ]]; then
    backend_name=${BASH_REMATCH[1]}
  elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then
    varname=${BASH_REMATCH[1]}
    varval=${BASH_REMATCH[2]}
    if [[ ${varname} == 'acl_host' ]]; then
      cat <<EOF >>/etc/haproxy/haproxy.cfg
${SSL_COMMENT}    use_backend ${backend_name} if host_${backend_name}
EOF
    fi
  fi
done <${conffile}

cat <<EOF >>/etc/haproxy/haproxy.cfg

#---------------------------------------------------------------------
# static backend for serving up images, stylesheets and such
#---------------------------------------------------------------------
#backend static
#    balance     roundrobin
#    server      static 127.0.0.1:4331 check
EOF

cat <<EOF >>/etc/haproxy/haproxy.cfg

backend certbot
    # docroot must be relative to chroot dir
    http-request set-header X-LUA-LOADFILE-DOCROOT /docroot
    http-request use-service lua.static-server
EOF

cat <<EOF >>/etc/haproxy/haproxy.cfg

#---------------------------------------------------------------------
# application backends
#---------------------------------------------------------------------
backend ${DEFAULT_BACKEND}
    balance     roundrobin                                    # Balance algorithm
    option httpchk HEAD / HTTP/1.1\r\nHost:\ localhost        # Check the server application is up and healty - 200 status code
    default-server check maxconn 100
    # server servername1 ${SERV_TPL}:${SERV_PORT}
    server-template websrv 1-100 ${SERV_TPL}:${SERV_PORT} check disabled
EOF

while read line; do
  if [[ $line =~ ^"["(.+)"]"$ ]]; then
    backend_name=${BASH_REMATCH[1]}
    cat <<EOF >>/etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
backend ${backend_name}
    balance     roundrobin                                    # Balance algorithm
    option httpchk HEAD / HTTP/1.1\r\nHost:\ localhost        # Check the server application is up and healty - 200 status code
EOF
  elif [[ $line =~ ^([_[:alpha:]][_[:alnum:]]*)"="(.*) ]]; then
    varname=${BASH_REMATCH[1]}
    varval=${BASH_REMATCH[2]}

    if [[ ${varname} == 'maxconn' ]]; then
      cat <<EOF >>/etc/haproxy/haproxy.cfg
    default-server check maxconn ${varval}
EOF
    elif [[ ${varname} == 'server' ]]; then
      count=0
      echo "Setting servers for '${backend_name}': ${varval}"
      for i in ${varval}; do
        cat <<EOF >>/etc/haproxy/haproxy.cfg
    server ${backend_name}_${count} ${i} enabled
EOF
        ((count++))
      done
    fi
  fi
done <${conffile}

cat <<EOF >>/etc/haproxy/haproxy.cfg
#-------------------these-lines-are-important-between-backends-and-eof
EOF


echo "Recreated /etc/haproxy/haproxy.cfg - reload of HAProxy needed."
