#!/bin/bash

#
# Usage: ./hostname-change.sh deploy.dev.bserve.link
#

NEW_HOSTNAME=${1}

hostnamectl set-hostname ${NEW_HOSTNAME}

cat >/etc/hostname <<EOF
${NEW_HOSTNAME}
EOF

cat >/etc/hosts <<EOF
127.0.1.1 ${NEW_HOSTNAME}
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF

# hostname --fqdn
# hostname
# domainname
# ypdomainname
# nisdomainname
# dnsdomainname

# hostnamectl status
# hostnamectl set-hostname fqdn.host.name
